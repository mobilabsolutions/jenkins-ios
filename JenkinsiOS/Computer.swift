//
//  Computer.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Computer{
    
    /// The computer's display name
    var displayName: String
    /// The icon's file name
    var icon: String
    /// Whether or not the computer is idle
    var idle: Bool
    /// Whether or not the computer is a jnlp agent
    var jnlpAgent: Bool
    /// Whether or not launch is supported on the given computer
    var launchSupported: Bool
    /// Whether or not manual launch is allowed on the given computer
    var manualLaunchAllowed: Bool
    /// The number of executors on the computer
    var numExecutors: Int
    /// Whether or not the computer is offline
    var offline: Bool
    /// The (optional) reason for the computer being offline
    var offlineCauseReason: String?
    /// Whether or not the computer is temporarily offline
    var temporarilyOffline: Bool?
    /// The corresponding monitor data
    var monitorData: MonitorData?
    
    /// Optionally initialize a Computer object
    ///
    /// - parameter json: The json from which to initialize the computer
    ///
    /// - returns: An initialized Computer object or nil, if initialization faild
    init?(json: [String: AnyObject]){
        guard let displayName = json["displayName"] as? String, let icon = json["icon"] as? String, let idle = json["idle"] as? Bool
            else { return nil }
        guard let jnlpAgent = json["jnlpAgent"] as? Bool, let launchSupported = json["launchSupported"] as? Bool, let manualLaunchAllowed = json["manualLaunchAllowed"] as? Bool
            else { return nil }
        guard let numExecutors = json["numExecutors"] as? Int, let offline = json["offline"] as? Bool
            else { return nil }
    
        self.displayName = displayName
        self.icon = icon
        self.idle = idle
        self.jnlpAgent = jnlpAgent
        self.launchSupported = launchSupported
        self.manualLaunchAllowed = manualLaunchAllowed
        self.numExecutors = numExecutors
        self.offline = offline
        
        temporarilyOffline = json["temporarilyOffline"] as? Bool
        offlineCauseReason = json["offlineCauseReason"] as? String
        
        if let monitorDataJson = json["monitorData"] as? [String: AnyObject]{
            monitorData = MonitorData(json: monitorDataJson)
        }
    }
}
