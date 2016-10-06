//
//  Plugin.swift
//  JenkinsiOS
//
//  Created by Robert on 06.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Plugin{
    var active: Bool
    var bundled: Bool?
    var deleted: Bool?
    var downgradable: Bool?
    var enabled: Bool?
    var hasUpdate: Bool?
    var longName: String?
    var pinned: Bool?
    var shortName: String
    var supportsDynamicLoad: String?
    var url: URL?
    var version: String?
    var dependencies: [Dependency] = []
    
    init?(json: [String: AnyObject]){
        guard let active = json[Constants.JSON.active] as? Bool,
              let shortName = json[Constants.JSON.shortName] as? String
            else { return nil }
        self.active = active
        self.shortName = shortName
        
        bundled = json[Constants.JSON.bundled] as? Bool
        deleted = json[Constants.JSON.deleted] as? Bool
        downgradable = json[Constants.JSON.downgradable] as? Bool
        enabled = json[Constants.JSON.enabled] as? Bool
        hasUpdate = json[Constants.JSON.hasUpdate] as? Bool
        longName = json[Constants.JSON.longName] as? String
        pinned = json[Constants.JSON.pinned] as? Bool
        supportsDynamicLoad = json[Constants.JSON.supportsDynamicLoad] as? String
        
        if let urlString = json[Constants.JSON.url] as? String{
            url = URL(string: urlString)
        }
        
        version = json[Constants.JSON.version] as? String
        
        if let dependenciesJSON = json[Constants.JSON.dependencies] as? [[String: AnyObject]]{
            for dependecyJSON in dependenciesJSON{
                if let dependecy = Dependency(json: dependecyJSON){
                    dependecies.append(dependency)
                }
            }
        }
    }
}
