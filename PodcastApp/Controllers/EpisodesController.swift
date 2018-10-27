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

    }

    // MARK: - Setup Work
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)

        tableView.tableFooterView = UIView() // removes horizontal lines
    }

    // MARK: - UITableView

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
        print("Play episode", episode.title)

        // add/display a view to entire window
        let window = UIApplication.shared.keyWindow

        // This will load the view designed in the nib file
        let playerDetailsView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView

        playerDetailsView.episode = episode

        playerDetailsView.frame = self.view.frame
        window?.addSubview(playerDetailsView)
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
