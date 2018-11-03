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

    func downloadEpisode(episode: Episode) {
        print("Download episode using Alamofire at stream url:", episode.streamUrl)

        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            }.response { (resp) in
                print(resp.destinationURL?.absoluteURL ?? "")

                // update UserDefaults downloaded episodes with this temp file
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()

                guard let index = downloadedEpisodes.index(where: { $0.title == episode.title && $0.author == episode.author }) else {return}

                downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""

                // update UserDefaults with new array that will contain the episode with the fileUrl

                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)

                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodesKey)
                } catch let err {
                    print("Failed to encode downloaded episodes with file url update:", err)
                }


        }

    }

    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {

        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")

        guard let url = URL(string: secureFeedUrl) else {return}

        DispatchQueue.global(qos: .background).async {
            print("Before parser")
            let parser = FeedParser(URL: url)
            print("After parser")
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
