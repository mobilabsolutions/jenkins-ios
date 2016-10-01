//
//  Result.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Result{
    var duration: Double
    var empty: Bool
    var failCount: Int
    var passCount: Int
    var skipCount: Int
    var suites: [Suite] = []
    
    init?(json: [String: AnyObject]){
        guard let duration = json[Constants.JSON.duration] as? Double,
              let empty = json[Constants.JSON.empty] as? Bool,
              let failCount = json[Constants.JSON.failCount] as? Int,
              let passCount = json[Constants.JSON.passCount] as? Int,
              let skipCount = json[Constants.JSON.skipCount] as? Int
            else { return nil }
        
        self.duration = duration
        self.empty = empty
        self.failCount = failCount
        self.passCount = passCount
        self.skipCount = skipCount
        
        if let suitesJson = json[Constants.JSON.suites] as? [[String: AnyObject]]{
            for suiteJson in suitesJson{
                if let suite = Suite(json: suiteJson){
                    suites.append(suite)
                }
            }
        }
    }
}
