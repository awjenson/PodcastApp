//
//  APIService.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/21/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit // needed for FeedParser


// conform to Decodable protocol
struct SearchResults:Decodable {
    let resultCount: Int
    let results: [Podcast] // class must conform to Decodable
}

class APIService {

    // singleton is shared
    static let shared = APIService()
    let baseiTunesSearchURL = "https://itunes.apple.com/search"

    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {

        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")

        guard let url = URL(string: secureFeedUrl) else {return}
        let parser = FeedParser(URL: url)
        parser.parseAsync { (result) in

            print("Successfully parsed feed", result.isSuccess)

            if let err = result.error {
                print("Failed to parse XML feed:", err)
                return
            }

            guard let feed = result.rssFeed else {return}

            // anytime you do refactoring you should remove the lines that reference self because we are no longer in the self object view controller. Instead call the completionHandler
            let episodes = feed.toEpisodes()
            completionHandler(episodes)
        }
    }



    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("Searching for podcasts...")



        // dictionary w/ searchText allows for us to search for names with a space
        // "media" allows us to only display podcasts
        let parameters = ["term": searchText, "media": "podcast"]

        Alamofire.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in

            if let err = dataResponse.error {
                print("Failed to contact yahoo", err)
                return
            }

            guard let data = dataResponse.data else {return}

            do {
                print(3)
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                print(searchResult.resultCount)

                completionHandler(searchResult.results)

//                self.podcasts = searchResult.results
//                self.tableView.reloadData()

            } catch let decodeErr {
                print("Failed to decode: \(decodeErr)")
            }
        }
        print(2)

    }


}
