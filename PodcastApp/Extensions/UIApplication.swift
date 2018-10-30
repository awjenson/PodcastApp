//
//  UIApplication.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/29/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
