//
//  PodcastCell.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/22/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit

class PodcastCell: UITableViewCell {

    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            // when we search for a podcast with the searchBar
            // the returned API data fills up these properites
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName

        }
    }

    
}
