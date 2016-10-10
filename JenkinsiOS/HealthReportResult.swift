//
//  HealthReportResult.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class HealthReportResult{
    
    var description: String
    //FIXME: This should be the actual url of the item, not only a part of its path
    var iconUrl: String
    var score: Int
    var iconClassName: String
    
    init?(json: [String: AnyObject]){
        guard let description = json["description"] as? String,
            let iconUrl = json["iconUrl"] as? String,
            let score = json["score"] as? Int,
            let iconClassName = json["iconClassName"] as? String
            else{ return nil }
        
        self.description = description
        self.iconUrl = iconUrl
        self.score = score
        self.iconClassName = iconClassName
        
        print("Icon url: \(iconUrl)")
    }
}
