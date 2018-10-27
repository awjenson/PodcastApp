//
//  RSSFeed.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/26/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
import FeedKit

extension RSSFeed {

    func toEpisodes() -> [Episode] {

        let imageUrl = iTunes?.iTunesImage?.attributes?.href

        var episodes = [Episode]() // blank Episode array
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            // load image
            if episode.imageUrl == nil {
                // if we don't get an episode image, then use the podcast show image
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        return episodes
    }



}
