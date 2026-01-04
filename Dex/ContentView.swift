//
//  ContentView.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2025. 12. 27..
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm: PokedexViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default
    )

    private var pokedex: FetchedResults<Pokemon>

    @State private var searchText: String = ""
    @State private var filterByFavourite: Bool = false

    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []

        // search predicate a %@ - search term
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }

        // Filter by favourite
        if filterByFavourite {
            predicates.append(NSPredicate(format: "favourite== %d", true))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    init(context: NSManagedObjectContext) {
        _vm = StateObject(wrappedValue: PokedexViewModel(context: context))
    }

    var body: some View {
        if pokedex.isEmpty{
            ContentUnavailableView {
                Label("No pokemon", image: ".nopokemon")
            } description: {
                Text("There aren't any pokemmon yet. \nFetch some to get started!")
            } actions: {
                Button("Fetch pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    Task { await vm.getPokemon() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        else {
            NavigationStack {
                List {
                    Section {
                        ForEach(pokedex, id: \.objectID) { pokemon in
                            NavigationLink(value: pokemon) {
                                PokemonRow(pokemon: pokemon)
                            }
                        }

                    } footer: {
                        PokedexFooter(vm: vm)
                    }
                }
                .navigationTitle("Pokedex")
                .searchable(text: $searchText, prompt: "Search a pokemon")
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .onChange(of: filterByFavourite) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .navigationDestination(for: Pokemon.self) { pokemon in
                    Text(pokemon.name ?? "no name")
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
}
        

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ContentView(context: context)
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
}
