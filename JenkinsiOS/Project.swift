//
//  Project.swift
//  JenkinsiOS
//
//  Created by Robert on 08.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Project{
    
    var name: String
    var url: URL
    
    init?(json: [String: AnyObject]){
        guard let name = json[Constants.JSON.name] as? String,
              let urlString = json[Constants.JSON.url] as? String,
              let url = URL(string: urlString)
            else { return nil }
        self.name = name
        self.url = url
    }
}
