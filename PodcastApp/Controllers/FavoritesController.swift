//
//  FavoritesController.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/31/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit

// UICollectionViewDelegateFlowLayout allows you to design size of cells
class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Parameters

    fileprivate let cellId = "cellId"
    var podcasts = UserDefaults.standard.savedPodcasts()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView?.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }

    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        // get the class by using .self
        collectionView?.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellId)

        // delete a favorite item
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView?.addGestureRecognizer(gesture)
    }

    @objc fileprivate func handleLongPress(gesture: UILongPressGestureRecognizer) {
        print("Capture Long Press")

        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else {return}

        let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in

            let selectedPodcast = self.podcasts[selectedIndexPath.item]

            // where we remove the podcast object from collection view
            self.podcasts.remove(at: selectedIndexPath.item)
            self.collectionView?.deleteItems(at: [selectedIndexPath])

            // remove your favorited podcast from UserDefaults
            UserDefaults.standard.deletePodcast(podcast: selectedPodcast)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UICollectionView Delegate / Spacing Methods

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritePodcastCell
        cell.podcast = self.podcasts[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // create 2 column grid
        let width = (view.frame.width - 3 * 16) / 2

        // increase the height for the full image
        return CGSize(width: width, height: width + 46)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        episodesController.podcast = self.podcasts[indexPath.item]

        navigationController?.pushViewController(episodesController, animated: true)
    }




}
