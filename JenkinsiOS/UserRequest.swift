//
//  UserRequest.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class UserRequest{

    /// The url that defines the request
    var requestUrl: URL
    /// The account that should be used in this user request
    var account: Account
    
    /// The url that should be used for api interaction
    var apiURL: URL{
        get{
            var components = URLComponents(url: requestUrl.appendingPathComponent("/api/json"), resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "pretty", value: "false")]
            components?.port = account.port
            
            if let additionalQueryItems = additionalQueryItems{
                components?.queryItems?.append(contentsOf: additionalQueryItems)
            }
            
            return components?.url ?? requestUrl
        }
    }
    
    /// Any additional query items that should be used in the api url
    private var additionalQueryItems: [URLQueryItem]?
    
    /// Initialiser for a User Request
    ///
    /// - parameter requestUrl:           The url that characterizes the request
    /// - parameter account:              The account that should be used for the account
    /// - parameter additionalQueryItems: Additional query items that should be used for the request
    ///
    /// - returns: <#return value description#>
    init(requestUrl: URL, account: Account, additionalQueryItems: [URLQueryItem]? = nil){
        self.requestUrl = requestUrl.using(scheme: "https", at: account.port)!
        self.account = account
        self.additionalQueryItems = additionalQueryItems
    }
}

//MARK: - Convenience functions for special user requests
extension UserRequest{
    
    /// Return the user request specific to getting the list of plugins
    ///
    /// - parameter account: The account for which the user request should be create
    ///
    /// - returns: The fitting user request object
    static func userRequestForPlugins(account: Account) -> UserRequest{
        let url = account.baseUrl.appendingPathComponent(Constants.API.plugins)
        let additionalComponents = Constants.API.pluginsAdditionalQueryItems
        
        return UserRequest(requestUrl: url, account: account, additionalQueryItems: additionalComponents)
    }
    
    /// Return the user request specific to getting the list of users
    ///
    /// - parameter account: The account for which the user request should be create
    ///
    /// - returns: The fitting user request object
    static func userRequestForUsers(account: Account) -> UserRequest{
        let url = account.baseUrl.appendingPathComponent(Constants.API.users)
        
        return UserRequest(requestUrl: url, account: account)
    }
    
    /// Return the user request specific to getting the list of jobs
    ///
    /// - parameter account: The account for which the user request should be create
    ///
    /// - returns: The fitting user request object
    static func userRequestForJobList(account: Account) -> UserRequest{
        let url = account.baseUrl
        let additionalComponents = Constants.API.jobListAdditionalQueryItems
        
        return UserRequest(requestUrl: url, account: account, additionalQueryItems: additionalComponents)
    }
        
    /// Return the user request specific to getting the list of computers
    ///
    /// - parameter account: The account for which the user request should be create
    ///
    /// - returns: The fitting user request object
    static func userRequestForComputers(account: Account) -> UserRequest{
        let url = account.baseUrl.appendingPathComponent(Constants.API.computer)
        
        return UserRequest(requestUrl: url, account: account)
    }
    
    /// Return the user request specific to getting the build queue
    ///
    /// - parameter account: The account for which the user request should be create
    ///
    /// - returns: The fitting user request object
    static func userRequestForBuildQueue(account: Account) -> UserRequest{
        let url = account.baseUrl.appendingPathComponent(Constants.API.buildQueue)
        
        return UserRequest(requestUrl: url, account: account)
    }
}
