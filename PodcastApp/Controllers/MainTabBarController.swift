//
//  MainTabBarController.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/21/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
         super.viewDidLoad()

        UINavigationBar.appearance().prefersLargeTitles = true

        tabBar.tintColor = .purple

        setupViewControllers()

        setupPlayerDetailsView()

        perform(#selector(maximizePlayerDetails), with: nil, afterDelay: 1)
    }

    @objc func minimizePlayerDetails() {

        maximizedTopAnchorConstraint.isActive = true // switch
        maximizedTopAnchorConstraint.constant = 0
        minimizedTopAnchorConstraint.isActive = false // switch

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            // any time you modify your anchors or constraints, call self.view.layoutIfNeeded()
            self.view.layoutIfNeeded()

        }, completion: nil)
    }

    @objc func maximizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = true // switch
        maximizedTopAnchorConstraint.constant = 0
        minimizedTopAnchorConstraint.isActive = false // switch

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            // any time you modify your anchors or constraints, call self.view.layoutIfNeeded()
            self.view.layoutIfNeeded()

        }, completion: nil)
    }

    // MARK: - Setup Functions

    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!

    fileprivate func setupPlayerDetailsView() {
        print("Setting up PlayerDetailsView")

        let playerDetailsView = PlayerDetailsView.initFromNib()
        playerDetailsView.backgroundColor = .red

//        view.addSubview(playerDetailsView) // addSubview before doing autoAnchoring
        view.insertSubview(playerDetailsView, belowSubview: tabBar)

        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false // enables auto layout


        // removed constant parameter in constraint(equalTo:)
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)



        maximizedTopAnchorConstraint.isActive = true

        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
//        minimizedTopAnchorConstraint.isActive = true

        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }



    func setupViewControllers() {
        viewControllers = [
            generateNavigationController(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(for: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(for: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))]
    }

    // MARK: - Helper Functions

    fileprivate func generateNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {

        let navController = UINavigationController(rootViewController: rootViewController)

        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }

}
