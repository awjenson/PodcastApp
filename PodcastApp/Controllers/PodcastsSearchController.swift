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

    let podcasts = [
        Podcast(name: "Lets Build That App", artistName: "Brian Voong"),
        Podcast(name: "Some Podcast", artistName: "Some Author")
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }

    // MARK: - UISearchBar

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        // TODO: Add Alamofire to search iTunes API
        let url = "https://itunes.apple.com/search?term=\(searchText)"
        Alamofire.request(url).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("Failed to contact yahoo", err)
                return
            }

            guard let data = dataResponse.data else {return}
            let dummyString = String(data: data, encoding: .utf8)
            print(dummyString ?? "")
        }

    }

    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        let podcast = self.podcasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.name)\n\(podcast.artistName)"
        cell.textLabel?.numberOfLines = -1
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }

}
