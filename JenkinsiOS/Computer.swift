//
//  Computer.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Computer{
    
    var displayName: String
    //FIXME: this should be the icon's actual url
    var icon: String
    var idle: Bool
    var jnlpAgent: Bool
    var launchSupported: Bool
    var manualLaunchAllowed: Bool
    var numExecutors: Int
    var offline: Bool
    var offlineCauseReason: String?
    var monitorData: [String: AnyObject]?
    
    init?(json: [String: AnyObject]){
        guard let displayName = json["displayName"] as? String, let icon = json["icon"] as? String, let idle = json["idle"] as? Bool
            else { return nil }
        guard let jnlpAgent = json["jnplAgent"] as? Bool, let launchSupported = json["launchSupported"] as? Bool, let manualLaunchAllowed = json["manualLaunchAllowed"] as? Bool
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
        
        offlineCauseReason = json["offlineCauseReason"] as? String
        monitorData = json["monitorData"] as? [String: AnyObject]
    }
}
