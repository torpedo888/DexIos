//
//  Stats.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2026. 01. 11..
//

import SwiftUI
import Charts

struct Stats: View {
    var pokemon: Pokemon!

    var body: some View {
        Chart(pokemon.stats){ stat in
            BarMark(x: .value("Value",stat.value),
                    y: .value("Name", stat.name))
            .annotation(position:.trailing) {
                Text("\(stat.value)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary) // ezzel jobban beleolvad a hatterbe
                    .padding(.top, -5)

            }
        }
        .frame(height: 200)
        .padding([.horizontal, .bottom])
        .foregroundStyle(pokemon.typeColor)
        .chartXScale(domain: 0...pokemon.highestStat.value + 50)
    }
}

#Preview {
    Stats(pokemon: PersistenceController.previewPokemon)
}
