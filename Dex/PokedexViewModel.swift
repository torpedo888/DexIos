//
//  PokedexViewModel.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2026. 01. 04..
//


import SwiftUI
import SwiftData

@MainActor
final class PokedexViewModel: ObservableObject {
   // private let fetcher: FetchService // your type
    private var context: ModelContext?

    private let fetcher = FetchService()

    func attach(context: ModelContext) { self.context = context }

//    init(context: ModelContext) {
//        self.context = context
//    }

    private var ctx: ModelContext {
        guard let context = context else {
            preconditionFailure("ModelContext not attached to PokedexViewModel. Call attach(context:) before use.")
        }
        return context
    }

    func getPokemon() async {
        // Load first generation
        for i in 1..<152 {
            do {
                let fetchedPokemon = try await fetcher.fetchPokemon(i)

                ctx.insert(fetchedPokemon)
            } catch {
                print("Fetch error for \(i):", error)
            }
        }

        do { try ctx.save() } catch { print("Final save error:", error) }

        await storeSpritesMissingOnly()
    }

    /// Fetch only rows missing sprites, then download & save.
    func storeSpritesMissingOnly() async {
        let descriptor = FetchDescriptor<Pokemon>(
            predicate: #Predicate { $0.sprite == nil || $0.shiny == nil },
            sortBy: [] // add SortDescriptor(\.id) if you want ordering
        )

        do {
            let pokemons = try ctx.fetch(descriptor)
            await downloadAndSaveSprites(for: pokemons)
        } catch {
            print("Error fetching missing sprites:", error)
        }
    }

    func downloadAndSaveSprites(for pokemons: [Pokemon]) async {
        Task {
            do {
                for pokemon in pokemons {
                    //data lekerdezese es letarolasa az url-bol .0 - ez a data .1 -ez lenne a response
                    pokemon.sprite = try await URLSession.shared
                        .data(from: pokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared
                        .data(from: pokemon.shinyURL).0

                    try ctx.save()

                    print("Stored sprites for \(pokemon.id) : \(pokemon.name.capitalized)")
                }
            }
            catch {
                print("Error storing sprites:", error)
            }
        }
    }
}
