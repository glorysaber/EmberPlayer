//
//  MediaItemModelDatabaseAdapter.swift
//  EmberPlayer
//
//  Created by Stephen Kac on 6/4/22.
//

import Foundation
import CoreData
import MediaPlayer

@MainActor
class MediaItemModelDatabaseAdapter: MediaModelDatabase {

  var context: NSManagedObjectContext
  var cachedItem: Item?

  func save(_ mediaItem: MediaModelItem) {
    do {
      let item = try fetchOrCreate(for: mediaItem.url)

      item.seekerTime = mediaItem.currentTime.seconds

      try context.save()
    } catch {
      fatalError("")
    }
  }

  init(context: NSManagedObjectContext) {
    self.context = context
  }

  func getItem(for url: URL) -> MediaModelItem {
    do {
      let item = try fetchOrCreate(for: url)
      return MediaModelItem(currentTime: CMTime(seconds: item.seekerTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), url: item.url ?? url)
    } catch {
      fatalError("")
    }
  }

  private func fetchOrCreate(for url: URL) throws -> Item {

    if let cachedItem = cachedItem, cachedItem.url == url {
      return cachedItem
    }

    let request = NSFetchRequest<Item>(entityName: Item.description())
    request.predicate = NSPredicate(format: "url = %@", url as CVarArg)

    let result = try context.fetch(request)

    let item = try result.first ?? {
      let item = Item(context: context)
      item.url = url
      item.timestamp = Date()

      try context.save()

      return item
    }()

    cachedItem = item

    return item
  }
}
