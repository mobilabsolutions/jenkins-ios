//
//  MonitorData.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class MonitorData{
    
    /// The number of avaible bytes of physical memory
    var availablePhysicalMemory: Double?
    /// The number of available bytes of swap space
    var availableSwapSpace: Double?
    /// The total number of bytes of physical memory
    var totalPhysicalMemory: Double?
    /// The total number of bytes of swap space
    var totalSwapSpace: Double?
    
    /// Initialize a MonitorData object
    ///
    /// - parameter json: The json from which to initialize the monitor data
    ///
    /// - returns: An initialized MonitorData object
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
