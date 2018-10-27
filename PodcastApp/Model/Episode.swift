//
//  Episode.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/23/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let description: String

    var imageUrl: String?

    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.description ?? ""

        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
}
