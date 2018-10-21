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
    }

    // MARK: - Setup Functions

    func setupViewControllers() {
        viewControllers = [
            generateNavigationController(for: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(for: ViewController(), title: "Search", image: #imageLiteral(resourceName: "search")),
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