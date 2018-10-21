//
//  APIService.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/21/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
import Alamofire


// conform to Decodable protocol
struct SearchResults:Decodable {
    let resultCount: Int
    let results: [Podcast] // class must conform to Decodable
}

class APIService {

    // singleton is shared
    static let shared = APIService()

    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("Searching for podcasts...")

        let url = "https://itunes.apple.com/search"

        // dictionary w/ searchText allows for us to search for names with a space
        // "media" allows us to only display podcasts
        let parameters = ["term": searchText, "media": "podcast"]

        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in

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
