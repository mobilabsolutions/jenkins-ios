//
//  Dependency.swift
//  JenkinsiOS
//
//  Created by Robert on 06.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Dependency{
    
    var optional: Bool
    var shortName: String
    var version: String
    
    init?(json: [String: AnyObject]){
        guard let optional = json[Constants.JSON.optional] as? Bool,
              let shortName = json[Constants.JSON.shortName] as? String,
              let version = json[Constants.JSON.version] as? String
            else { return nil }
        
        self.optional = optional
        self.shortName = shortName
        self.version = version
    }
}
