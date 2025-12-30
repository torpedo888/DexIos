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

    private let fetcher = FetchService()

    var body: some View {
        NavigationView {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink {
                        Text(pokemon.name ?? "no name")
                    } label: {
                        Text(pokemon.name ?? "no name")
                    }
                }
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
