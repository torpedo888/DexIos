//
//  PokedexViewModel.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2026. 01. 04..
//


import SwiftUI
import CoreData

@MainActor
final class PokedexViewModel: ObservableObject {
   // private let fetcher: FetchService // your type
    private let context: NSManagedObjectContext

    private let fetcher = FetchService()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getPokemon(from all: [Pokemon]) async {
        // Load first generation
        for i in 1..<152 {
            do {
                let fetched = try await fetcher.fetchPokemon(i)

                let pokemon = Pokemon(context: context)
                pokemon.id = fetched.id
                pokemon.name = fetched.name
                pokemon.types = fetched.types
                pokemon.hp = fetched.hp
                pokemon.attack = fetched.attack
                pokemon.defense = fetched.defense
                pokemon.specialAttack = fetched.specialAttack
                pokemon.specialDefense = fetched.specialDefense
                pokemon.speed = fetched.speed
                pokemon.spriteURL = fetched.spriteURL
                pokemon.shinyURL = fetched.shinyURL

                // Save periodically to avoid memory spikes and speed up
                if i % 10 == 0 {
                    try context.save()
                }
            } catch {
                print("Fetch error for \(i):", error)
            }
        }

        do { try context.save() } catch { print("Final save error:", error) }

        await storeSpritesMissingOnly()
    }

    /// Fetch only rows missing sprites, then download & save.
    func storeSpritesMissingOnly() async {
        let request: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "sprite == nil"),
            NSPredicate(format: "shiny == nil")
        ])
        request.sortDescriptors = []

        do {
            let pokemons = try context.fetch(request)
            await downloadAndSaveSprites(for: pokemons)
        } catch {
            print("Error fetching missing sprites:", error)
        }
    }

    func downloadAndSaveSprites(for pokemons: [Pokemon]) {
        Task {
            do {
                for pokemon in pokemons {
                    //data lekerdezese es letarolasa az url-bol .0 - ez a data .1 -ez lenne a response
                    pokemon.sprite = try await URLSession.shared
                        .data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared
                        .data(from: pokemon.shinyURL!).0

                    try context.save()

                    print("Stored sprites for \(pokemon.id) : \(pokemon.name!.capitalized)")
                }
            }
            catch {
                print("Error storing sprites:", error)
            }
        }
    }


}
