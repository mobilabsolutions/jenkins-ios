//
//  UserRequest.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

struct UserRequest{
    var url: URL
    var username: String?
    var password: String?
    var port: Int?
    
    var apiURL: URL{
        get{
            var components = URLComponents(url: url.appendingPathComponent("/api/json"), resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "pretty", value: "false")]
            
            return components?.url ?? url
        }
    }
}
