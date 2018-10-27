//
//  PlayerDetailsView.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/26/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {

    var episode: Episode! {
        didSet {
            episodeTitleLabel.text = episode.title

            guard let url = URL(string: episode.imageUrl ?? "") else {return}

            episodeImageView.sd_setImage(with: url) // removed completionHandler because default is nil
        }
    }

    @IBOutlet weak var episodeImageView: UIImageView!

    @IBOutlet weak var episodeTitleLabel: UILabel!
    

    @IBAction func handleDismiss(_ sender: Any) {
        self.removeFromSuperview() // superView is the window defined in EpisodesController
    }

}
