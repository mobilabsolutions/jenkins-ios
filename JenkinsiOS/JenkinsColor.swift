//
//  JenkinsColor.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

/// The color of a given Job, indicating its status
enum JenkinsColor: String{
    case blue = "blue"
    case red = "red"
    case yellow = "yellow"
    case disabled = "disabled"
    case aborted = "aborted"
    case notBuilt = "notbuilt"
    
    case yellowAnimated = "yellow_anime"
    case redAnimated = "red_anime"
    case blueAnimated = "blue_anime"
    case abortedAnimated = "aborted_anime"
    case disabledAnimated = "disabled_anime"
    case notBuiltAnimated = "notbuilt_anime"
}
