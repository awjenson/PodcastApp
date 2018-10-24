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

        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")

        guard let url = URL(string: secureFeedUrl) else {return}
        let parser = FeedParser(URL: url)
        parser.parseAsync { (result) in


            print("Successfully parsed feed", result.isSuccess)

            // associative enumeration values
            switch result {

            case let .rss(feed):

                var episodes = [Episode]() // blan Episode arry

                feed.items?.forEach({ (feedItem) in

                    let episode = Episode(title: feedItem.title ?? "")
                    episodes.append(episode)

                    print(feedItem.title ?? "")
                })

                self.episodes = episodes

                DispatchQueue.main.async {
                    // update the UI
                    self.tableView.reloadData()
                }

                break

            case let .failure(error):
                print("Failed to parse feed", error)
                break

            default:
                print("Found a feed...")
            }


        }
    }

    fileprivate let cellId = "cellId"

    struct Episode {
        let title: String
    }

    var episodes = [Episode]()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

    }

    // MARK: - Setup Work
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView() // removes horizontal lines
    }

    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let episode = episodes[indexPath.row]
        cell.textLabel?.text = episode.title
        return cell
    }








}