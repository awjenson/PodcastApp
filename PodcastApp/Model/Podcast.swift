//
//  Podcast.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/21/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    // property names need to match JSON key names
    // make them var and optional to avoid JSON errors
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}


