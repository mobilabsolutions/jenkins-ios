//
//  Suite.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Suite {
    /// The test cases that were run in the suite
    var cases: [Case] = []
    /// The duration it took for the suite to run
    var duration: Double?
    /// The id of the suite
    var id: String?
    /// The name fo the suite
    var name: String?
    /// The stderr output that the Suite created
    var stderr: String?
    /// The standard output that the Suite created
    var stdout: String?
    /// The timestamp at which the suite was run
    var timestamp: String?

    /// Optionally initialize a Suite
    ///
    /// - parameter json: The json from which to initialize the Suite
    ///
    /// - returns: A Suite or nil, if initialization failed
    init?(json: [String: AnyObject]) {
        duration = json[Constants.JSON.duration] as? Double
        id = json[Constants.JSON.id] as? String
        name = json[Constants.JSON.name] as? String
        stderr = json[Constants.JSON.stderr] as? String
        stdout = json[Constants.JSON.stdout] as? String
        timestamp = json[Constants.JSON.timestamp] as? String

        if let casesJson = json[Constants.JSON.cases] as? [[String: AnyObject]] {
            for caseJson in casesJson {
                cases.append(Case(json: caseJson))
            }
        }
    }
}
