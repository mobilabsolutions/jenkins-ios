//
//  MonitorData.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class MonitorData{
    
    var availablePhysicalMemory: Double?
    var availableSwapSpace: Double?
    var totalPhysicalMemory: Double?
    var totalSwapSpace: Double?
    
    init(json: [String: AnyObject]){
        for partJson in json{
            if let dataJson = partJson.value as? [String: AnyObject]{
                availablePhysicalMemory = dataJson[Constants.JSON.availablePhysicalMemory] as? Double ?? availablePhysicalMemory
                availableSwapSpace = dataJson[Constants.JSON.availableSwapSpace] as? Double ?? availableSwapSpace
                totalPhysicalMemory = dataJson[Constants.JSON.totalPhysicalMemory] as? Double ?? totalPhysicalMemory
                totalSwapSpace = dataJson[Constants.JSON.totalSwapSpace] as? Double ?? totalSwapSpace
            }
        }
    }
    
}
