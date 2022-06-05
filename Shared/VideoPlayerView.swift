//
//  VideoPlayer.swift
//  EmberPlayer
//
//  Created by Stephen Kac on 6/4/22.
//

import SwiftUI
import AVKit

protocol PlayerViewModel: ObservableObject {
  @MainActor
  var player: AVPlayer { get }

  @MainActor
  var isPlaying: Bool { get set }

  @MainActor
  func play()
}

@MainActor
struct VideoPlayerView<Model: PlayerViewModel>: View {

  @ObservedObject private var model: Model

  var body: some View {
    VStack {
      if (model.player.currentItem == nil) {
        Text("Open a media file using the 􀈂 button, and select EmberPlayer.")
      } else {
        VideoPlayer(player: model.player)
        .onAppear { model.play() }
      }
    }
  }

  init(model: Model) {
    _model = ObservedObject(wrappedValue: model)
  }
}

struct VideoPlayerView_Previews: PreviewProvider {

  private static var model = MediaModel(database: MediaItemModelDatabaseAdapter(context: PersistenceController.preview.container.viewContext), url: Bundle.main.url(forResource: "testVideo", withExtension: "mp4")!)

  static var previews: some View {
    VideoPlayerView(model: model)
  }
}
