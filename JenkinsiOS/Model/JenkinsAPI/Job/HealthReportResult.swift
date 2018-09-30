//
//  HealthReportResult.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class HealthReportResult {
    var description: String
    var score: Int
    var iconClassName: String

    /// Optionally initialize a HealthReportResult
    ///
    /// - parameter json: The json from which to initialize the HealthReportResult from
    ///
    /// - returns: The initialized HealthReportResult or nil, if initialization failed
    init?(json: [String: AnyObject]) {
        guard let description = json["description"] as? String,
            let score = json["score"] as? Int,
            let iconClassName = json["iconClassName"] as? String
        else { return nil }

        self.description = description
        self.score = score
        self.iconClassName = iconClassName
    }
}
