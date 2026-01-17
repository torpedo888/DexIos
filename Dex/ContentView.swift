//
//  ContentView.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2025. 12. 27..
//

import SwiftUI
import SwiftData

struct ContentView: View {
  //  @StateObject private var vm: PokedexViewModel

    @StateObject private var vm = PokedexViewModel()

    @Environment(\.modelContext) private var modelContext
    //@Query(sort: \Pokemon.self.id, animation: .default) private var pokedex: [Pokemon]
 //   @Query(sort: [SortDescriptor(\Pokemon.id)], animation: .default) private var pokedex: [Pokemon]

    @Query(sort: [SortDescriptor(\Pokemon.id)], animation: .default)
        private var pokedexAll: [Pokemon]

    @State private var searchText: String = ""
    @State private var filterByFavourite: Bool = false

    private var dynamicPredicate: Predicate<Pokemon> {
        #Predicate<Pokemon> { pokemon in
            // ha a favourite (csillag) es a searchtextbe is beirnak valamit a szureshez
            if filterByFavourite && !searchText.isEmpty {
                pokemon.favourite && pokemon.name
                    .localizedStandardContains(searchText)
            } else if !searchText.isEmpty {
                pokemon.name.localizedStandardContains(searchText)
            } else if filterByFavourite {
                pokemon.favourite
            } else { //ez az else a minden mas eset. true- tehat mindent visszaad
                true
            }
        }

    }

    private var filtered: [Pokemon] {
        pokedexAll.filter { p in
                let matchesSearch = searchText.isEmpty || p.name.localizedStandardContains(searchText)
                let matchesFav = !filterByFavourite || p.favourite
                return matchesSearch && matchesFav
            }
        }


    private var filteredPokemons: [Pokemon] {
        pokedexAll.filter { p in
            let matchesSearch = searchText.isEmpty || p.name.localizedStandardContains(searchText)
            let matchesFav = !filterByFavourite || p.favourite
            return matchesSearch && matchesFav
        }
    }

    var body: some View {
        Group {
            if filtered.isEmpty{
                    ContentUnavailableView {
                        Label("No pokemon", image: ".nopokemon")
                    } description: {
                        Text("There aren't any pokemmon yet. \nFetch some to get started!")
                    } actions: {
                        Button("Fetch pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                            Task {
                             //   vm.attach(context: modelContext)
                                await vm.getPokemon()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

            }
            else {
                NavigationStack {
                    List {
                        Section {
                            ForEach(filteredPokemons, id: \.persistentModelID) { pokemon in
                                NavigationLink(value: pokemon) {
                                    PokemonRow(pokemon: pokemon)
                                }
                                .swipeActions (edge: .leading) {
                                    Button(pokemon.favourite ? "Remove from faourites" : "Add to favourites",
                                           systemImage: "star") {
                                        pokemon.favourite.toggle()

                                        do {
                                            try modelContext.save()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                                .tint(pokemon.favourite ? .gray : .yellow)
                            }

                        } footer: {
                            if pokedexAll.count < 151 {
                                PokedexFooter(vm: vm)
                            }
                        }
                    }
                    .navigationTitle("Pokedex")
                    .searchable(text: $searchText, prompt: "Search a pokemon")
                    .autocorrectionDisabled()
                    .animation(.default, value: searchText)
                    .navigationDestination(for: Pokemon.self) { pokemon in
                        PokemonDetail(pokemon: pokemon)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                withAnimation {
                                    filterByFavourite.toggle()
                                }
                            } label: {
                                Label("Filter By Favorites", systemImage:
                                        filterByFavourite ? "star.fill" : "star")
                            }
                            .tint(.yellow)
                        }
                    }
                }
            }
        }
        .task {
            vm.attach(context: modelContext)
        }

    }
}
        

#Preview {
    ContentView()
        .modelContainer(PersistenceController.preview)
}
