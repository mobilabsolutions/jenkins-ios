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
    var userId: String?
    var userName: String?
    
    init?(json: [String: AnyObject]){
        guard let shortDescription = json["shortDescription"] as? String
            else { return nil }
        
        self.userName = json["userName"] as? String
        self.userId = json["userId"] as? String
        self.shortDescription = shortDescription
    }
}
