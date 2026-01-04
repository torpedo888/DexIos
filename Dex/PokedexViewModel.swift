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

    func getPokemon() async {
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
                pokemon.sprite = fetched.sprite
                pokemon.shiny = fetched.shiny

                // Save periodically to avoid memory spikes and speed up
                if i % 10 == 0 {
                    try context.save()
                }
            } catch {
                print("Fetch error for \(i):", error)
            }
        }

        do { try context.save() } catch { print("Final save error:", error) }
    }
}
