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

    fileprivate let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        // get the class by using .self
        collectionView?.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellId)
    }

    // MARK: - UICollectionView Delegate / Spacing Methods

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
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




}
