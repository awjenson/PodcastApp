//
//  Episode.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/23/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
import FeedKit

// conforms to Codable protocol for downloading episodes into UserDefaults
// Codable allows for Episode to conform to Encodeable and Decodable
struct Episode: Codable {
    let title: String
    let pubDate: Date
    let description: String
    let author: String
    let streamUrl: String

    var imageUrl: String?

    init(feedItem: RSSFeedItem) {
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? "" // url stream of audio file

        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
}
