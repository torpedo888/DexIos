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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default
)
    private var pokedex: FetchedResults<Pokemon>

    @State private var searchText: String = ""

    private let fetcher = FetchService()

    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []

        // search predicate a %@ - search term
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }

        // Filter by favourite

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink (value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)

                        VStack(alignment:.leading) {
                            Text(pokemon.name!.capitalized)
                                .fontWeight(.bold)

                            let names: [String] = (pokemon.types as? [String])?.sorted() ?? []

                            PokemonTypeBadges(typeNames: names)
                        }
                    }
                }
            }
            .navigationTitle("Pokedex")
            .searchable(text: $searchText, prompt: "Search a pokemon")
            .autocorrectionDisabled()
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                Text(pokemon.name ?? "no name")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }
            }
        }
    }

    private func getPokemon() {
        Task {
            for id in 1..<152 {
                do {
                    let fetchPokemon = try await fetcher.fetchPokemon(id)

                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchPokemon.id
                    pokemon.name = fetchPokemon.name
                    pokemon.types = fetchPokemon.types
                    pokemon.hp = fetchPokemon.hp
                    pokemon.attack = fetchPokemon.attack
                    pokemon.defense = fetchPokemon.defense
                    pokemon.specialAttack = fetchPokemon.specialAttack
                    pokemon.specialDefense = fetchPokemon.specialDefense
                    pokemon.speed = fetchPokemon.speed
                    pokemon.sprite = fetchPokemon.sprite
                    pokemon.shiny = fetchPokemon.shiny

                    try viewContext.save()
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
