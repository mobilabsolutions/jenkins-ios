//
//  UserRequest.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class UserRequest{

    var requestUrl: URL
    var account: Account
    
    var apiURL: URL{
        get{
            var components = URLComponents(url: requestUrl.appendingPathComponent("/api/json"), resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "pretty", value: "false")]
            
            return components?.url ?? requestUrl
        }
    }
    
    init(requestUrl: URL, account: Account){
        self.requestUrl = requestUrl.using(scheme: "https", at: account.port)!
        self.account = account
    }
}
