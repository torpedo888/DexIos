//
//  DexApp.swift
//  Dex
//
//  Created by Ferenc Batorligeti on 2025. 12. 27..
//

import SwiftUI

@main
struct DexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
