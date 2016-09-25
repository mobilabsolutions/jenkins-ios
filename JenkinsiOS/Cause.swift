//
//  Cause.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Cause{
    
    var shortDescription: String
    var userId: String
    var userName: String
    
    init?(json: [String: AnyObject]){
        guard let shortDescription = json["shortDescription"] as? String,
            let userId = json["userId"] as? String,
            let userName = json["userName"] as? String
            else { return nil }
        
        self.userName = userName
        self.userId = userId
        self.shortDescription = shortDescription
    }
}
