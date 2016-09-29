//
//  Account.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Account: NSObject, NSCoding{
    var baseUrl: URL
    var username: String?
    var password: String?
    var port: Int?
    
    init(baseUrl: URL, username: String?, password: String?, port: Int?){
        self.baseUrl = baseUrl
        self.username = username
        self.password = password
        self.port = port
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let baseUrl = aDecoder.decodeObject(forKey: "baseUrl") as? URL
            else { return nil }
        
        self.baseUrl = baseUrl
        port = aDecoder.decodeObject(forKey: "port") as? Int
        username = aDecoder.decodeObject(forKey: "username") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(baseUrl, forKey: "baseUrl")
        aCoder.encode(port, forKey: "port")
        aCoder.encode(username, forKey: "username")
    }
}
