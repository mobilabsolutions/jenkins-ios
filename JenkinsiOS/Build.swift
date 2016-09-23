//
//  Build.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Build{
    
    var number: Int
    var url: URL
    
    
    //TODO: Add actions/causes
    
    var building: Bool?
    var description: String?
    
    var displayName: String?
    var fullDisplayName: String?
    
    var id: String?
    var result: String?
    var builtOn: String?
    
    var duration: TimeInterval?
    var estimatedDuration: TimeInterval?
    
    
    init?(json: [String: AnyObject], minimalVersion: Bool = false){
        guard let number = json["number"] as? Int, let urlString = json["url"] as? String, let url = URL(string: urlString)
            else { return nil }
        
        self.number = number
        self.url = url
        
        if minimalVersion{
            return
        }
        
        building = json["building"] as? Bool
        description = json["description"] as? String
        displayName = json["displayName"] as? String
        fullDisplayName = json["fullDisplayName"] as? String
        id = json["id"] as? String
        result = json["result"] as? String
        builtOn = json["builtOn"] as? String
        
        duration = json["duration"] as? TimeInterval
        estimatedDuration = json["estimatedDuration"] as? TimeInterval
    }
}
