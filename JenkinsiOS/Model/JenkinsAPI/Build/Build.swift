//
//  Build.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Build: Favoratible, CustomDebugStringConvertible {
    /// The build's number
    var number: Int
    /// The build's url
    var url: URL

    /// The actions associated with the build
    var actions: Actions?

    /// Whether or not the build is currently building
    var building: Bool?
    /// The build's description
    var buildDescription: String?

    /// The build's short display name
    var displayName: String?
    /// The build's full display name
    var fullDisplayName: String?

    /// The build's id
    var id: String?
    /// The build's result (SUCCESS, FAILURE, etc.)
    var result: String?
    /// Which machine the build was built on
    var builtOn: String?

    /// The duration of the build
    var duration: TimeInterval?
    /// The estimated duration of the build
    var estimatedDuration: TimeInterval?
    /// The date that the build was started on
    var timeStamp: Date?

    /// The changes that took place before the build
    var changeSets: [ChangeSet] = []

    /// The artifacts that were produced with the build
    var artifacts: [Artifact] = []

    /// The url that points to the Build's console output
    var consoleOutputUrl: URL {
        let components = URLComponents(url: url.appendingPathComponent(Constants.API.consoleOutput), resolvingAgainstBaseURL: true)
        return components?.url ?? url
    }

    var allChangeItems: [Item] {
        return changeSets.flatMap({ $0.items })
    }

    /// Is the build information based on "full version" JSON?
    var isFullVersion = false

    /// Optionally initialise a build
    ///
    /// - parameter json:           The json used for initialization
    /// - parameter minimalVersion: Whether or not the json actually is a minimal version of all the possible build attributes
    ///
    /// - returns: An initialised Build object or nil
    init?(json: [String: AnyObject], minimalVersion: Bool) {
        guard let number = json["number"] as? Int, let urlString = json["url"] as? String, let url = URL(string: urlString)
        else { return nil }

        self.number = number
        self.url = url

        if let timeStampInterval = json["timestamp"] as? TimeInterval {
            // For some reason, Jenkins use milliseconds for their timestamp
            timeStamp = Date(timeIntervalSince1970: timeStampInterval / 1000.0)
        }

        if !minimalVersion {
            addAdditionalFields(from: json)
        }
    }

    /// Add values for fields in the full job category
    ///
    /// - parameter json: The JSON parsed data from which to get the values for the additional fields
    func addAdditionalFields(from json: [String: AnyObject]) {
        if let actionsJson = json["actions"] as? [[String: AnyObject]] {
            actions = Actions(json: actionsJson)
        }

        building = json["building"] as? Bool
        buildDescription = json["description"] as? String
        displayName = json["displayName"] as? String
        fullDisplayName = json["fullDisplayName"] as? String
        id = json["id"] as? String
        result = json["result"] as? String
        builtOn = json["builtOn"] as? String

        duration = json["duration"] as? TimeInterval
        estimatedDuration = json["estimatedDuration"] as? TimeInterval

        for candidateKey in ["changeSet", "changeSets"] {
            if let changeSetJson = json[candidateKey] as? [String: AnyObject] {
                let changeSet = ChangeSet(json: changeSetJson)
                if changeSet.items.count > 0 {
                    changeSets.append(changeSet)
                }
            } else if let changeSetsJson = json[candidateKey] as? [[String: AnyObject]] {
                changeSets = changeSetsJson.map { ChangeSet(json: $0) }
            }
        }

        if let artifactsJson = json[Constants.JSON.artifacts] as? [[String: AnyObject]] {
            for artifactJson in artifactsJson {
                if let artifact = Artifact(json: artifactJson, with: self.url) {
                    artifacts.append(artifact)
                }
            }
        }

        isFullVersion = true
    }

    var debugDescription: String {
        return "Build #\(number) at \(url)"
    }
}
