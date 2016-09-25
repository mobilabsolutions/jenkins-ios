//
//  Account.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Account{
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
}
