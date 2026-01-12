//
//  PokemonRow.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2026. 01. 04..
//
import SwiftUI
import Foundation

struct PokemonRow: View {
    let pokemon: Pokemon

    var body: some View {
        HStack(spacing: 12) {
            if pokemon.sprite == nil {
                        AsyncImage(url: spriteURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
            } else {
                pokemon.spriteImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .onAppear {
                        print("image from db: \(pokemon.id)")
                    }
            }



            VStack(alignment: .leading) {
                HStack {
                    Text(pokemon.name?.capitalized ?? "Unknown")
                        .fontWeight(.bold)

                    if pokemon.favourite ?? false {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }

                PokemonTypeBadges(typeNames: typeNames)
            }
        }
    }

    private var spriteURL: URL? {
        // Adjust depending on your Core Data model type:
        if let s = pokemon.spriteURL as? String { return URL(string: s) }
        return pokemon.spriteURL as? URL
    }

    private var typeNames: [String] {
        (pokemon.types as? [String])?.sorted() ?? []
    }
}
