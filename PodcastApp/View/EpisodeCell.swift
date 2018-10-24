//
//  EpisodeCell.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/24/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {


    var episode: Episode! {
        didSet {
            // code for cellForRow at indexPath
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
        }

    }

    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }


    
}
