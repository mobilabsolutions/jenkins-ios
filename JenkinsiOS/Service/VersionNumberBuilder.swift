//
//  VersionNumberBuilder.swift
//  JenkinsiOS
//
//  Created by Robert on 26.11.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import Foundation

class VersionNumberBuilder {
    private static let versionKey = "CFBundleShortVersionString"
    private static let buildNumberKey = "CFBundleVersion"

    var fullVersionNumberDescription: String? {
        guard let versionNumber = self.versionNumber
        else { return nil }

        var versionString = "Version \(versionNumber)"

        if let buildNumber = self.buildNumber {
            versionString += " (\(buildNumber))"
        }

        return versionString
    }

    var versionNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: VersionNumberBuilder.versionKey) as? String
    }

    var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: VersionNumberBuilder.buildNumberKey) as? String
    }
}
