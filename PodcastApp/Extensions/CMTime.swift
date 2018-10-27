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

        // isNotANumber (isNaN)
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }

        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 60 / 60
        let timeFormatString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return timeFormatString
    }

}


