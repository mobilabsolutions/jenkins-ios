//
//  Build.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Build: CustomDebugStringConvertible{
    
    var number: Int
    var url: URL
    
    
    //TODO: Add actions/causes
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
    
    var changeSet: ChangeSet?
    
    var consoleOutputUrl: URL{
        get{
            var components = URLComponents(url: url.appendingPathComponent("/logText/progressiveHtml"), resolvingAgainstBaseURL: true)
            components?.queryItems = [
                URLQueryItem(name: "start", value: "0")
            ]
            return components?.url ?? url
        }
    }
    
    init?(json: [String: AnyObject], minimalVersion: Bool = false){
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
            changeSet = ChangeSet(json: changeSetJson)
        }
    }
    
    var debugDescription: String{
        return "Build #\(number) at \(url)"
    }
}
