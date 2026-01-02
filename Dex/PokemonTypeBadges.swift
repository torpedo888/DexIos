//
//  PokemonTypeBadges.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2026. 01. 01..
//



import SwiftUI

struct PokemonTypeBadges: View {
    let typeNames: [String]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(typeNames, id: \.self) { name in
                Text(name.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 5)
                    .background(Color(name.capitalized))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    PokemonTypeBadges(typeNames: ["grass", "poison"])
        .padding()
}

