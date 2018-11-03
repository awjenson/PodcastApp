//
//  EpisodesController.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/23/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {

    var podcast: Podcast? {
        didSet {
            // access the podcast when it's set on this controller
            navigationItem.title = podcast?.trackName

            // fetch feed
            fetchEpisodes()
        }
    }

    fileprivate func fetchEpisodes() {

        // FeedKit code
        guard let feedUrl = podcast?.feedUrl else {return}

        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }

    fileprivate let cellId = "cellId"

    var episodes = [Episode]() // initial empty Episode array

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBarButtons()


    }

    fileprivate func setupNavigationBarButtons() {

        // check if podcast has already been saved as favorite
        let savedPodcasts = UserDefaults.standard.savedPodcasts()

        let hasFavorited = savedPodcasts.index(where: {
            $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName
        }) != nil

        if hasFavorited {
            // setting up our heart icon
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
                UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
            ]
        }



    }

    @objc fileprivate func handleSaveFavorite() {
        print("Saving info into UserDefaults")

        guard let podcast = self.podcast else {return}

        // fetch our saved podcasts first
        

        // 1. Transform a list of Podcasts into Data
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)

        // Store data in UserDefaults
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)

        showBadgeHightlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
    }

    fileprivate func showBadgeHightlight() {
        // highlight favorite tab in tab bar controller
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
    }

    @objc fileprivate func handleFetchSavedPodcasts() {
        print("Fetching saved Podcasts from UserDefaults")

        // how to retrieve our Podcast object from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else {return}

        let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]

        savedPodcasts?.forEach({ (p) in
            print(p.trackName ?? "")
        })

    }



    // MARK: - Setup Work
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)

        tableView.tableFooterView = UIView() // removes horizontal lines
    }

    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            // save episode in UserDefaults
            print("Downloading episode into UserDefaults")
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)

        }

        return [downloadAction]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode // see var episode didSet in EpisodeCell
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let episode = self.episodes[indexPath.row]

        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }


}
