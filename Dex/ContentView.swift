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
    @Query(sort: [SortDescriptor(\Pokemon.id)], animation: .default) private var pokedex: [Pokemon]

    @State private var searchText: String = ""
    @State private var filterByFavourite: Bool = false

//    private var dynamicPredicate: NSPredicate {
//        var predicates: [NSPredicate] = []
//
//        // search predicate a %@ - search term
//        if !searchText.isEmpty {
//            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
//        }
//
//        // Filter by favourite
//        if filterByFavourite {
//            predicates.append(NSPredicate(format: "favourite== %d", true))
//        }
//
//        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//    }

//    init(context: ModelContext) {
//        //_vm = StateObject(wrappedValue: PokedexViewModel(context: context))
//
//    }

    var body: some View {
        Group {
                if pokedex.isEmpty{
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
                            ForEach(pokedex) { pokemon in
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
                            if pokedex.count < 151 {
                                PokedexFooter(vm: vm)
                            }
                        }
                    }
                    .navigationTitle("Pokedex")
                    .searchable(text: $searchText, prompt: "Search a pokemon")
                    .autocorrectionDisabled()
                    .navigationDestination(for: Pokemon.self) { pokemon in
                        PokemonDetail(pokemon: pokemon)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                filterByFavourite.toggle()
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
