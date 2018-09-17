//
//  Child.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Child {
    /// The child's number
    var number: Int?
    /// The child's url
    var url: URL?

    /// Optionally initialize a Child object
    ///
    /// - parameter json: The json from which to initialize the child
    ///
    /// - returns: A freshly initialized child object or nil, if initialization failed
    init?(json: [String: AnyObject]) {
        number = json[Constants.JSON.number] as? Int
        if let urlString = json[Constants.JSON.url] as? String {
            url = URL(string: urlString)
        }
    }
}
