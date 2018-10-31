//
//  PlayerDetailsView.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/26/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit
import AVKit // play audio files
import MediaPlayer // control audio on the background

class PlayerDetailsView: UIView {

    // changes everytime we play a new episode
    var episode: Episode! {
        didSet {
            // Mini
            miniTitleLabel.text = episode.title
            // Max
            episodeTitleLabel.text = episode.title
            authorLabel.text = episode.author

            setupNowPlayingInfo()
            setupAudioSession()
            playEpisode()

            guard let url = URL(string: episode.imageUrl ?? "") else {return}

            // removed completionHandler because default is nil
            // Mini
            miniEpisodeImageView.sd_setImage(with: url)
            // Max
            episodeImageView.sd_setImage(with: url)

            displayArtworkImageInLockedScreen(url: url)
        }
    }

    fileprivate func displayArtworkImageInLockedScreen(url: URL) {
        // Display Artwork Image in Locked Screen View
        miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
            // lock screen artwork setup code

            let image = self.episodeImageView.image ?? UIImage()

            let artworkItem = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                return image
            })

            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkItem
        }
    }

    fileprivate func setupNowPlayingInfo() {
        // Lock Screen Now Playing Info

        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // local variable instance so you can use it in multiple methods
    var panGesture: UIPanGestureRecognizer!

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
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            // See CMTime extension file for toDisplayString()
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()

            self?.updateCurrentTimeSlider()
        }
    }

    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
        let percentage = currentTimeSeconds / durationSeconds

        self.currentTimeSlider.value = Float(percentage)
    }


    deinit {
        print("PlayerDetailsView memory being reclaimed...")
    }


    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        // gestureRecognizers only occurs on the miniPlayerView
        miniPlayerView.addGestureRecognizer(panGesture)

        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))

    }

    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        print("Maxing Statck View Dismissal")

        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {

            let translation = gesture.translation(in: superview)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.maximizedStackView.transform = .identity

                // 50 was number used in tutorial
                if translation.y > 50 {
                    // UIApplication extension created called mainTabBarController()
                    UIApplication.mainTabBarController()?.minimizePlayerDetails()
                }
            }, completion: nil)
        }
    }

    fileprivate func setupAudioSession() {
        // Enables auidio play in the background
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }

    fileprivate func elapsedTime() {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    }

    // Lock screen code
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        // import MediaPlayer above

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)

            self.setupElapsedTime(playbackRate: 1)
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)

            self.setupElapsedTime(playbackRate: 0)
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in

            self.handlePlayPause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))

        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }

    fileprivate func setupElapsedTime(playbackRate: Float) {
        let episodeTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = episodeTime

        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }

    var playlistEpisodes = [Episode]()

    fileprivate func changeTrack(moveForward: Bool) {
        let offset = moveForward ? 1 : playlistEpisodes.count - 1
        if playlistEpisodes.count == 0 {return}
        let currentEpisodeIndex = playlistEpisodes.index { (episode) -> Bool in
            return self.episode.title == episode.title
        }
        guard let index = currentEpisodeIndex else {return}
        self.episode = playlistEpisodes[(index + offset) % playlistEpisodes.count]
    }

    @objc fileprivate func handlePreviousTrack() {
        changeTrack(moveForward: false)
    }

    @objc fileprivate func handleNextTrack() {
        changeTrack(moveForward: true)
    }

    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(1, 3) // allows you to monitor your player when it starts
        let times = [NSValue(time: time)]

        // player has sa reference to self
        // self has a reference to player
        // '[weak self] in' breaks retain cycle
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing")
            // Once the episode starts playing is when we can to animate
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }

    fileprivate func setupLockScreenDuration() {
        guard let duration = player.currentItem?.duration else {return}

        let durationSeconds = CMTimeGetSeconds(duration)

        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }

    fileprivate func setupInteruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInteruption), name: .AVAudioSessionInterruption, object: nil)
    }

    @objc fileprivate func handleInteruption(notification: Notification) {
        print("Interuption observed")

        guard let userInfo = notification.userInfo else {return}
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}

        if type == AVAudioSessionInterruptionType.began.rawValue {
            print("Interuption began")
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            print("Interuption ended")

            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}

            // checks whether or not we should resume playback
            if options == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()


        setupRemoteControl()
        setupGestures()
        setupInteruptionObserver()
        observePlayerCurrentTime()
        observeBoundaryTime()
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }

    fileprivate func handlePanChanged(gesture: UIPanGestureRecognizer) {
        print("changed")
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)

        // fade out occurs as we get to 200
        self.miniPlayerView.alpha = 1 + translation.y / 200

        self.maximizedStackView.alpha = -translation.y / 200

        print(translation.y)
    }

    fileprivate func handlePanEnded(gesture: UIPanGestureRecognizer) {
        // get the translation
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)

        print("Ended", velocity.y)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.transform = .identity // original state without transition

            // -200 because we're using 200 above (make sure they match)
            if translation.y < -200 || velocity.y < -500 {
                // extension created called mainTabBarController()
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }, completion: nil)
    }

    @objc func handleTapMaximize() {
        // extension created called mainTabBarController()
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
    }

    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }


    // MARK: - IBOutlet


    @IBOutlet weak var miniPlayerView: UIView!

    @IBOutlet weak var miniEpisodeImageView: UIImageView!

    @IBOutlet weak var miniTitleLabel: UILabel!

    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
            miniPlayPauseButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }

    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.addTarget(self, action: #selector(handleFastForward(_:)), for: .touchUpInside)
            miniFastForwardButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }

    
    @IBOutlet weak var maximizedStackView: UIStackView!
    
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
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            self.setupElapsedTime(playbackRate: 0)
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

        // call a method from another class (MainTabBarController)
        // UIApplication extension created called mainTabBarController()
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
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

        // For lock screen display
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds

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
