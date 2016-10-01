//
//  Author.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Author{
    var absoluteUrl: URL
    var fullName: String
    
    init?(json: [String: Any]){
        guard let absoluteUrlString = json[Constants.JSON.absoluteUrl] as? String, let fullName = json[Constants.JSON.fullName] as? String, let absoluteUrl = URL(string: absoluteUrlString)
            else { return nil }
        
        self.absoluteUrl = absoluteUrl
        self.fullName = fullName
    }
}
