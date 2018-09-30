//
//  UserList.swift
//  JenkinsiOS
//
//  Created by Robert on 08.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class UserList {
    /// The list of users
    var users: [User] = []

    /// Initialize a list of users
    ///
    /// - parameter json: The json from which to initialize the list of users
    ///
    /// - returns: An initialized UserList object
    init(json: [String: AnyObject]) {
        if let jsonUsers = json[Constants.JSON.users] as? [[String: AnyObject]] {
            for jsonUser in jsonUsers {
                if let user = User(json: jsonUser) {
                    users.append(user)
                }
            }
        }
    }
}
