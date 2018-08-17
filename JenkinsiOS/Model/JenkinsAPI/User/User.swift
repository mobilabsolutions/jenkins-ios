//
//  User.swift
//  JenkinsiOS
//
//  Created by Robert on 08.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class User {
    
    var fullName: String
    var id: String
    var absoluteUrl: URL
    var lastChange: Int?
    var project: Project?
    var description: String?
    
    /// Optionally initialize a User
    ///
    /// - parameter json: The json from which to initialize the User
    ///
    /// - returns: An initialized user object or nil, if the initialization failed
    init?(json: [String: AnyObject]){
        lastChange = json[Constants.JSON.lastChange] as? Int
        
        if let projectJson = json[Constants.JSON.project] as? [String: AnyObject]{
            project = Project(json: projectJson)
        }
        
        guard let userJson = json[Constants.JSON.user] as? [String: AnyObject]
            else { return nil }
        guard let fullName = userJson[Constants.JSON.fullName] as? String,
              let absoluteUrlString = userJson[Constants.JSON.absoluteUrl] as? String,
            let absoluteUrl = URL(string: absoluteUrlString), let id = userJson[Constants.JSON.id] as? String
            else { return nil }
        
        self.fullName = fullName
        self.absoluteUrl = absoluteUrl
        self.id = id
        
        self.description = userJson[Constants.JSON.description] as? String
    }
}
