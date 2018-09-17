//
//  Artifact.swift
//  JenkinsiOS
//
//  Created by Robert on 18.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Artifact {
    var filename: String
    var url: URL

    var size: Int?

    init?(json: [String: AnyObject], with buildUrl: URL) {
        guard let filename = json["fileName"] as? String,
            let relativePath = json["relativePath"] as? String
        else { return nil }

        self.filename = filename
        url = buildUrl.appendingPathComponent(Constants.API.artifact, isDirectory: true).appendingPathComponent(relativePath)
    }
}
