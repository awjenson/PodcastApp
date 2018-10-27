//
//  String.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/26/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation

extension String {
    func toSecureHTTPS() -> String {

        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
