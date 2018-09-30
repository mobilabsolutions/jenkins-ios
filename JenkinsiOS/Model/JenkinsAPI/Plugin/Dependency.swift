//
//  Dependency.swift
//  JenkinsiOS
//
//  Created by Robert on 06.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Dependency {
    /// Whether or not the dependency is optional
    var optional: Bool
    /// The dependency's shortened name
    var shortName: String
    /// The dependency's current version
    var version: String

    /// Optionally initialize a dependency
    ///
    /// - parameter json: The json from which the dependency should be initialized
    ///
    /// - returns: The initialized dependency or nil, if the initialization failed
    init?(json: [String: AnyObject]) {
        guard let optional = json[Constants.JSON.optional] as? Bool,
            let shortName = json[Constants.JSON.shortName] as? String,
            let version = json[Constants.JSON.version] as? String
        else { return nil }

        self.optional = optional
        self.shortName = shortName
        self.version = version
    }
}
