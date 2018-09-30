//
//  Project.swift
//  JenkinsiOS
//
//  Created by Robert on 08.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Project {
    /// The project's name
    var name: String
    /// The project's url
    var url: URL

    /// Optionally initialize a project
    ///
    /// - parameter json: The json from which to initialize the project
    ///
    /// - returns: The initialized Project or nil, if the initialization failed
    init?(json: [String: AnyObject]) {
        guard let name = json[Constants.JSON.name] as? String,
            let urlString = json[Constants.JSON.url] as? String,
            let url = URL(string: urlString)
        else { return nil }
        self.name = name
        self.url = url
    }
}
