//
//  Build.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Build: Favoratible, CustomDebugStringConvertible{
    
    var number: Int
    var url: URL
    
    var actions: Actions?
    
    var building: Bool?
    var description: String?
    
    var displayName: String?
    var fullDisplayName: String?
    
    var id: String?
    var result: String?
    var builtOn: String?
    
    var duration: TimeInterval?
    var estimatedDuration: TimeInterval?
    
    var changeSets: [ChangeSet] = []
    
    var consoleOutputUrl: URL{
        get{
            var components = URLComponents(url: url.appendingPathComponent(Constants.API.consoleOutput), resolvingAgainstBaseURL: true)
            components?.queryItems = Constants.API.consoleOutputQueryItems
            return components?.url ?? url
        }
    }
    
    /// Is the build information based on "full version" JSON?
    private(set) var isFullVersion = false
    
    init?(json: [String: AnyObject], minimalVersion: Bool){
        guard let number = json["number"] as? Int, let urlString = json["url"] as? String, let url = URL(string: urlString)
            else { return nil }
        
        self.number = number
        self.url = url
        
        if !minimalVersion{
            addAdditionalFields(from: json)
        }
    }
    
    /// Add values for fields in the full job category
    ///
    /// - parameter json: The JSON parsed data from which to get the values for the additional fields
    func addAdditionalFields(from json: [String: AnyObject]){
        
        if let actionsJson = json["actions"] as? [[String: AnyObject]]{
            actions = Actions(json: actionsJson)
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
        
        if let changeSetJson = json["changeSet"] as? [String: AnyObject]{
            let changeSet = ChangeSet(json: changeSetJson)
            if changeSet.items.count > 0{
                changeSets.append(changeSet)
            }
        }
            // It seems, as if Change Sets could also be in an array
        else if let changeSetsJson = json["changeSet"] as? [[String: AnyObject]]{
            changeSets = changeSetsJson.map({ (dict) -> ChangeSet in
                return ChangeSet(json: dict)
            })
        }
        
        isFullVersion = true
    }
    
    var debugDescription: String{
        return "Build #\(number) at \(url)"
    }
}
