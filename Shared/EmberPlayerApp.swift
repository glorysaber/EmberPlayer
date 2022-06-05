//
//  EmberPlayerApp.swift
//  Shared
//
//  Created by Stephen Kac on 6/4/22.
//

import SwiftUI

@MainActor
private class State {
  let persistenceController = PersistenceController.shared
  let errorModel = ErrorViewModel()
  // Must be lazy due to it using self before init.
  lazy var model = MediaModel(database: MediaItemModelDatabaseAdapter(context: persistenceController.container.viewContext)) { [weak self] error in
    self?.errorModel.error = error
  }
}

@main
@MainActor
struct EmberPlayerApp: App {
  // The state must be stored seperately in a class due to limitation on modifying state in a Struct.
  // The lazy var means accessing it is considered a mutating operation.
  private let state = State()

  var body: some Scene {
    WindowGroup {
      ErrorView(model: state.errorModel) {
        VideoPlayerView(model: state.model)
          .onOpenURL { url in
            // Handles any urls sent to us.
            state.errorModel.error = nil
            state.model.open(url: url)
          }
      }
    }
  }
}
