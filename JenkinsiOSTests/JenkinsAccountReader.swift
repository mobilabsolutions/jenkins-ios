//
//  JenkinsAccountReader.swift
//  JenkinsiOS
//
//  Created by Robert on 27.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class JenkinsAccountReader{
    
    static func getAccount(for classType: AnyClass) -> Account?{
        
        guard let resourceUrl = Bundle(for: classType).url(forResource: "Jenkins", withExtension: "plist")
            else { return nil }
        
        guard let dict = NSDictionary(contentsOf: resourceUrl)
            else { return nil }
        
       return getAccount(with: dict)
    }

    private static func getAccount(with dict: NSDictionary) -> Account?{
        guard let baseUrlString = dict.object(forKey: "URL") as? String, let baseUrl = URL(string: baseUrlString)
            else { return nil }
        
        let username = dict.object(forKey: "Username") as? String
        let password = dict.object(forKey: "API-Key") as? String
        let port = dict.object(forKey: "Port") as? Int
        
        return Account(baseUrl: baseUrl, username: emptyStringToNil(str: username),
                       password: emptyStringToNil(str: password), port: port, displayName: nil)
    }
    
    private static func emptyStringToNil(str: String?) -> String?{
        guard let str = str
            else { return nil }
        return str.isEmpty ? nil : str
    }
    
}
