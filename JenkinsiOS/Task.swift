//
//  Task.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Task{
    var name: String
    var url: URL?
    var color: JenkinsColor?
    
    init?(json: [String: AnyObject]){
        guard let name = json[Constants.JSON.name] as? String
            else { return nil }
        self.name = name
        
        if let urlString = json[Constants.JSON.url] as? String{
            url = URL(string: urlString)
        }
        
        if let colorString = json[Constants.JSON.color] as? String{
            color = JenkinsColor(rawValue: colorString)
        }
    }
}
