//
//  JenkinsActions.swift
//  JenkinsiOS
//
//  Created by Robert on 21.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

enum JenkinsAction{
    case restart
    case quietDown
    case cancelQuietDown
    case safeRestart
    
    func apiConstant() -> String{
        switch self{
            case .restart: return Constants.API.restart
            case .safeRestart: return Constants.API.safeRestart
            case .quietDown: return Constants.API.quietDown
            case .cancelQuietDown: return Constants.API.cancelQuietDown
        }
    }
}
