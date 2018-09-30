//
//  ChildReport.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ChildReport {
    /// The child report's child
    var child: Child?
    /// The result produced by the child report
    var result: Result?

    /// Initialize a ChildReport
    ///
    /// - parameter json: The json from which to initialize the ChildReport
    ///
    /// - returns: The initialized ChildReport object
    init(json: [String: AnyObject]) {
        if let childJson = json[Constants.JSON.child] as? [String: AnyObject] {
            child = Child(json: childJson)
        }
        if let resultJson = json[Constants.JSON.result] as? [String: AnyObject] {
            result = Result(json: resultJson)
        }
    }
}
