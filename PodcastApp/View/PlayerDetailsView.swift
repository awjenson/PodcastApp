//
//  PlayerDetailsView.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/26/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit
import AVKit // play audio files

class PlayerDetailsView: UIView {

    var episode: Episode! {
        didSet {
            episodeTitleLabel.text = episode.title
            authorLabel.text = episode.author

            playEpisode()

            guard let url = URL(string: episode.imageUrl ?? "") else {return}

            episodeImageView.sd_setImage(with: url) // removed completionHandler because default is nil


        }
    }

    fileprivate func playEpisode() {
        // pList > App Transport Security > Allow Arbitrary Loads > YES, to allow https
        print("Trying to play episode at url", episode.streamUrl)

        guard let url = URL(string: episode.streamUrl) else {return}

        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()

    // MARK: - IBOutlet

    @IBOutlet weak var episodeImageView: UIImageView!

    @IBOutlet weak var episodeTitleLabel: UILabel! {
        didSet {
            episodeTitleLabel.numberOfLines = 2
        }
    }

    @IBOutlet weak var authorLabel: UILabel!

    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }

    @objc func handlePlayPause() {

        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }


    // MARK: - IBAction

    @IBAction func handleDismiss(_ sender: Any) {
        self.removeFromSuperview() // superView is the window defined in EpisodesController
    }

}
