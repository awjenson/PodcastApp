//
//  PodcastsSearchController.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/21/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {

    var podcasts = [
        Podcast(trackName: "Lets Build That App", artistName: "Brian Voong"),
        Podcast(trackName: "Some Podcast", artistName: "Some Author")
    ]

    let cellId = "cellId"

    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Keep viewDidLoad as clean as possible
        setupSearchBar()
        setupTableView()

    }

    // MARK: - Setup Work

    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self // let us know when something happens in the searchBar
    }

    fileprivate func setupTableView() {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)

        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }

    // MARK: - UISearchBar

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        print(1)
        APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in

            self.podcasts = podcasts
            self.tableView.reloadData()
        }
    }

    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell

        let podcast = self.podcasts[indexPath.row]
        cell.podcast = podcast


//        let podcast = self.podcasts[indexPath.row]
//        cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
//        cell.textLabel?.numberOfLines = -1
//        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }

}
