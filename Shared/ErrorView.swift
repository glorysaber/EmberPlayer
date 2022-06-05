//
//  ErrorView.swift
//  EmberPlayer
//
//  Created by Admin on 6/5/22.
//

import SwiftUI

class ErrorViewModel: ObservableObject {
  @Published var error: Error?
}

struct ErrorView<Content: View>: View {

  @ObservedObject var model: ErrorViewModel

  @ViewBuilder
  var content: () -> Content

  var body: some View {
    if let error = model.error {
      VStack {
        Text("An error occurred.")
        Text(error.localizedDescription)
      }
    } else {
      content()
    }
  }
}

struct ErrorView_Previews: PreviewProvider {

  static let model = ErrorViewModel()

  static var previews: some View {
    ErrorView(model: model) {
      EmptyView()
    }
  }
}
