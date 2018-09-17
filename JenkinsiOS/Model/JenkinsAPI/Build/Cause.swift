//
//  Cause.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Cause {
    /// A short description of the cause
    var shortDescription: String
    /// The user id of the causing user
    var userId: String?
    /// The name of the causing user
    var userName: String?

    /// Optionally initialise a Cause
    ///
    /// - parameter json: The json from which to initialise the cause
    ///
    /// - returns: The initialsed Cause object
    init?(json: [String: AnyObject]) {
        guard let shortDescription = json["shortDescription"] as? String
        else { return nil }

        userName = json["userName"] as? String
        userId = json["userId"] as? String
        self.shortDescription = shortDescription
    }
}
