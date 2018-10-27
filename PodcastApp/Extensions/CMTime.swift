//
//  CMTime.swift
//  PodcastApp
//
//  Created by Andrew Jenson on 10/27/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import AVKit

extension CMTime {

    func toDisplayString() -> String {

        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60 // get seconds value
        let minutes = totalSeconds / 60 // get minutes value
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }

}


