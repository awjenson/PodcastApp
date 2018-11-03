//
//  Podcast.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/21/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation

// NSObject required for aCoder.encode
// NSCoding only works with class
class Podcast: NSObject, Decodable, NSCoding {

    // MARK: - Required methods for NSCoding
    func encode(with aCoder: NSCoder) {

        print("Trying to transform Podcast into Data")

        // TODO: Define strings as constants
        aCoder.encode(trackName ?? "", forKey: "trackNameKey")
        aCoder.encode(artistName ?? "", forKey: "artistNameKey")
        aCoder.encode(artworkUrl600 ?? "", forKey: "artworkNameKey")
        aCoder.encode(feedUrl ?? "", forKey: "feedKey")
    }

    required init?(coder aDecoder: NSCoder) {
        print("Trying to turn Data into Podcast")
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkNameKey") as? String
        self.feedUrl = aDecoder.decodeObject(forKey: "feedKey") as? String
    }

    // property names need to match JSON key names
    // make them var and optional to avoid JSON errors
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}


