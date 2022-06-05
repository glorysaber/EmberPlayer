//
//  MediaModel.swift
//  EmberPlayer
//
//  Created by Stephen Kac on 6/4/22.
//

@preconcurrency import Foundation
import AVKit
import MediaPlayer
import QuickLookThumbnailing

@MainActor

/// Allows the storage and retrieval of media items
protocol MediaModelDatabase {
  func save(_: MediaModelItem) throws
  func getItem(for: URL) throws -> MediaModelItem
}

/// Used to store the seek position for a media item.
struct MediaModelItem: Sendable {
  var currentTime: CMTime
  var url: URL
}

@MainActor
class MediaModel {
  let player = AVPlayer()

  // When this is set, it lets the view know it is time to update
  @Published var currentItemURL: URL?

  private var timeObserver: Any?

  private let database: any MediaModelDatabase

  private let onError: (Error) -> Void

  private var currentItem: MediaModelItem? {
    didSet {
      currentItemURL = currentItem?.url

      guard let currentItem = currentItem else {
        return
      }

      do {
      try database.save(currentItem)
      } catch {
        print("Failed to save current item seek time.")
      }
    }
  }

  convenience init(database: MediaModelDatabase, url: URL, onError: @escaping (Error) -> Void) {
    self.init(database: database, onError: onError)

    open(url: url)
  }

  required init(database: MediaModelDatabase, onError: @escaping (Error) -> Void) {
    self.database = database
    self.onError = onError

    // Allows AirPlay
    player.allowsExternalPlayback = true

    // Allows playing in background
    player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible

    // Saves the seek time
    timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] time in
      self?.currentItem?.currentTime = time
    }

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.playback, options: .allowAirPlay)
      try audioSession.setMode(.moviePlayback)
      try audioSession.setActive(true)
    } catch {
      print("Setting category to AVAudioSessionCategoryPlayback failed.")
    }
  }
}

extension MediaModel: PlayerViewModel {
  var isPlaying: Bool {
    set {
      player.rate = newValue ? 1.0 : 0.0
    }
    get {
      player.rate != 0
    }
  }

  func play() {
    player.rate = 1.0
  }

  func open(url: URL) {
    if url == currentItemURL {
      return
    }

    currentItem?.currentTime = player.currentTime()

    do {
      let currentItem = try database.getItem(for: url)
      self.currentItem = currentItem

      let avAsset = AVAsset(url: url)

      let avItem = AVPlayerItem(asset: avAsset)
      player.replaceCurrentItem(with: avItem)

      player.seek(to: currentItem.currentTime)

      play()
    } catch {
      onError(error)
    }
  }
}
