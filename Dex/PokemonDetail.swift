//
//  PokemonDetail.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2026. 01. 09..
//

import SwiftUI

struct PokemonDetail: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var pokemon: Pokemon

    @State private var showShiny = false

    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color:.black, radius: 10)

                AsyncImage(url: pokemon.sprite) { image in
                    image
                        .interpolation(.none) //megszunteti a pixelezodeset az image-nek
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color:.black, radius: 10)
                } placeholder: {
                    ProgressView()
                }
            }

            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color:.white, radius: 1)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background(Color(type.description.capitalized))
                        .clipShape(.capsule)
                }

                Spacer()

                Button {
                    pokemon.favourite.toggle()

                    do {
                        try viewContext.save()
                    } catch {
                        print(error)
                    }

                } label: {
                    Image(systemName: pokemon.favourite ?
                          "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }
            }
            .padding()

            Text("Stats")
                .font(.title)
                .padding(.bottom, -10)

            Stats(pokemon: pokemon)
                .padding()
        }
        .navigationTitle(pokemon.name!.capitalized)
    }
}

#Preview {
    NavigationStack {
        PokemonDetail()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
