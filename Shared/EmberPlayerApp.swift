//
//  EmberPlayerApp.swift
//  Shared
//
//  Created by Admin on 6/4/22.
//

import SwiftUI

@main
struct EmberPlayerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
