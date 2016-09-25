//
//  Action.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Actions{
    var causes: [Cause] = []
    var failCount: Int?
    var skipCount: Int?
    var totalCount: Int?
    var urlName: String?
    
    init(json: [[String: AnyObject]]){
        for action in json{
            if let causesJson = action["causes"] as? [[String: AnyObject]]{
                for causeJson in causesJson{
                    if let cause = Cause(json: causeJson){
                        causes.append(cause)
                    }
                }
            }
            
            // Set these fields to the value of that field in the json action
            // If it doesn't exist, set it to its previous value, as not to overwrite good data
            failCount = action["failCount"] as? Int ?? failCount
            skipCount = action["skipCount"] as? Int ?? skipCount
            totalCount = action["totalCount"] as? Int ?? totalCount
            urlName = action["urlName"] as? String ?? urlName
        }
    }
}
