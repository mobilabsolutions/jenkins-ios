//
//  View.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class View: CustomStringConvertible{
    var name: String
    var url: URL
    
    var description: String{
        return "View \"\(name)\""
    }
    
    init?(json: [String: AnyObject]){
        guard let name = json["name"] as? String, let urlString = json["url"] as? String,
            let url = URL(string: urlString)
            else { return nil }
        self.name = name
        self.url = url
    }
}
