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

    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(1, 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            // See CMTime extension file for toDisplayString()
            self.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self.player.currentItem?.duration
            self.durationLabel.text = durationTime?.toDisplayString()

            self.updateCurrentTimeSlider()
        }
    }

    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
        let percentage = currentTimeSeconds / durationSeconds

        self.currentTimeSlider.value = Float(percentage)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        observePlayerCurrentTime()

        let time = CMTimeMake(1, 3) // allows you to monitor your player when it starts
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            print("Episode started playing")
            // Once the episode starts playing is when we can to animate
            self.enlargeEpisodeImageView()
        }
    }

    // MARK: - IBOutlet

    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true

            episodeImageView.transform = shrunkenTransform
        }
    }


    @IBOutlet weak var currentTimeSlider: UISlider!

    @IBOutlet weak var currentTimeLabel: UILabel!

    @IBOutlet weak var durationLabel: UILabel!




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
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }

    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)

    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        }, completion: nil)
    }

    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.episodeImageView.transform = self.shrunkenTransform
        }, completion: nil)
    }

    // MARK: - IBAction

    @IBAction func handleDismiss(_ sender: Any) {
        self.removeFromSuperview() // superView is the window defined in EpisodesController
    }



    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        print("Slider value:", currentTimeSlider.value)

        // handles moving the slider and playing the audio at the selected slider value
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, 1)

        player.seek(to: seekTime)

    }

    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(delta, 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.currentTime()
        player.seek(to: seekTime)
    }

    @IBAction func handleRewind(_ sender: Any) {

        seekToCurrentTime(delta: -15)
    }

    @IBAction func handleFastForward(_ sender: Any) {

        seekToCurrentTime(delta: 15)
    }

    // changed sender from Any to UISlider
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }


}
