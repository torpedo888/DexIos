//
//  PokedexFooter.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2026. 01. 04..
//
import Foundation
import SwiftUI

struct PokedexFooter: View {
    @StateObject var vm: PokedexViewModel
    
    var body: some View {
        ContentUnavailableView {
            Label("Missing pokemon", image: ".nopokemon")
        } description: {
            Text("The fetch was interupted!\nFetch the rest of the pokemon.")
        } actions: {
            Button("Fetch pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                Task {
                    await vm.getPokemon()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
