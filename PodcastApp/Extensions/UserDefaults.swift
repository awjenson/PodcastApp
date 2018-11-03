//
//  UserDefaults.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/31/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
extension UserDefaults {

    // Parameters

    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadEpisodesKey = "downloadEpisodesKey"

    // Methods

    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else { return [] }
        return savedPodcasts
    }

    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }

    // episode must follow encodable protocol
    func downloadEpisode(episode: Episode) {

        do {
            // fetch whatever is inside UserDefaults with downloadedEpisodes()
            var episodes = downloadedEpisodes()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodesKey)

        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }

    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = UserDefaults.standard.data(forKey: UserDefaults.downloadEpisodesKey) else {return [] }

        do {
            // important to construct JSONDecoder()
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }
        // if fails return blank array
        return []
    }

    func deleteEpisode(episode: Episode) {
        // fetch whatever is inside UserDefaults with downloadedEpisodes()
        let savedEpisodes = downloadedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
            // you should use episode.collectionId to be safer with deletes
            return e.title != episode.title
        }

        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }

}

