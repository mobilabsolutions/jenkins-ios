//
//  Job.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Job: Favoratible {

    // MARK: - Minimal Version

    /// The job's name
    var name: String
    /// The job's url
    var url: URL
    /// The job's color indicating its current status
    var color: JenkinsColor?

    // MARK: - Full version

    /// The job's description
    var description: String?

    /// Whether or not the Job is currently buildable
    var buildable: Bool?
    /// All recently performed builds on the Job
    var builds: [Build] = []

    /// The results of health reports in the job
    var healthReport: [HealthReportResult] = []
    /// Whether or not the Job is currently in a queue
    var inQueue: Bool?
    /// Whether or not dependencies are kept in the Job
    var keepDependencies: Bool?

    /// The first performed build in the job
    var firstBuild: Build?
    /// The last build
    var lastBuild: Build?
    /// The last completed build
    var lastCompletedBuild: Build?
    /// The last failed build
    var lastFailedBuild: Build?
    /// The last stable build
    var lastStableBuild: Build?
    /// The last successful build
    var lastSuccessfulBuild: Build?
    /// The last unstable build
    var lastUnstableBuild: Build?
    /// The last unsuccessful build
    var lastUnsuccessfulBuild: Build?

    /// An array of special builds: First, last, last completed, etc.
    var specialBuilds: [(String, Build?)] = []

    /// The number of the next to be performed build
    var nextBuildNumber: Int?

    /// Is the job information based on "full version" JSON?
    var isFullVersion = false

    /// The job's build parameters, if any
    var parameters: [Parameter] = []

    /// Whether or not the job was previously built
    var wasBuilt: Bool {
        return color != .notBuilt
    }

    /// Optionally initialize a Job
    ///
    /// - parameter json:           The json from which to initialize the job
    /// - parameter minimalVersion: Whether or not the json represents a minimal version of the job
    ///
    /// - returns: The initialized Job object or nil, if initialization failed
    init?(json: [String: AnyObject], minimalVersion: Bool = false, isBuildMinimalVersion: Bool = true) {
        guard let nameUrlString = json[Constants.JSON.name] as? String,
            let name = nameUrlString.removingPercentEncoding,
            let urlString = json[Constants.JSON.url] as? String
        else {
            return nil
        }
        guard let url = URL(string: urlString)
        else {
            return nil
        }

        if let stringColor = json["color"] as? String {
            color = JenkinsColor(rawValue: stringColor)
        } else {
            color = JenkinsColor.folder
        }

        self.url = url
        self.name = name

        healthReport = (json["healthReport"] as? [[String: AnyObject]])?
            .map { HealthReportResult(json: $0) }.compactMap { $0 } ?? []

        lastBuild = json["lastBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)

        // The minimal version only contains these select fields
        if !minimalVersion {
            addAdditionalFields(from: json, isBuildMinimalVersion: isBuildMinimalVersion)
        }
    }

    /// Add values for fields in the full job category
    ///
    /// - parameter json: The JSON parsed data from which to get the values for the additional fields
    func addAdditionalFields(from json: [String: AnyObject], isBuildMinimalVersion: Bool) {
        if let stringColor = json["color"] as? String {
            color = JenkinsColor(rawValue: stringColor)
        }

        description = json["description"] as? String
        buildable = json["buildable"] as? Bool
        inQueue = json["inQueue"] as? Bool
        keepDependencies = json["keepDependencies"] as? Bool

        builds = (json["builds"] as? [[String: AnyObject]])?.map { Build(json: $0, minimalVersion: isBuildMinimalVersion) }.filter { $0 != nil }.map { $0! } ?? []

        // Get the interesting builds from the json data and, if they can be converted to a dictionary, try to initialize a Build from them
        firstBuild = json["firstBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["firstBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)
        lastBuild = json["lastBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)
        lastCompletedBuild = json["lastCompletedBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastCompletedBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)
        lastFailedBuild = json["lastFailedBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastFailedBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)
        lastStableBuild = json["lastStableBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastStableBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)
        lastSuccessfulBuild = json["lastSuccessfulBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastSuccessfulBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)
        lastUnstableBuild = json["lastUnstableBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastUnstableBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)
        lastUnsuccessfulBuild = json["lastUnsuccessfulBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastUnsuccessfulBuild"] as! [String: AnyObject], minimalVersion: isBuildMinimalVersion)

        nextBuildNumber = json["nextBuildNumber"] as? Int

        specialBuilds = [
            ("Last Build", lastBuild),
            ("Last Successful Build", lastSuccessfulBuild),
            ("Last Failed Build", lastFailedBuild),
            ("Last Unsuccessful Build", lastUnsuccessfulBuild),
            ("Last Completed Build", lastCompletedBuild),
            ("First Build", firstBuild),
        ]

        // Parse all the parameters
        parameters = []
        // For some reason there are multiple places in which the parameters may be defined. We
        // will a
        let possibleParameterDefinitionPlaces = [Constants.JSON.property, Constants.JSON.actions]

        for possibleParameterDefinitionPlace in possibleParameterDefinitionPlaces {
            if let properties = json[possibleParameterDefinitionPlace] as? [[String: Any]],
                let parametersJson = properties.first(where: { $0[Constants.JSON.parameterDefinitions] != nil })?[Constants.JSON.parameterDefinitions] as? [[String: Any]] {
                for parameterJson in parametersJson {
                    guard let parameter = Parameter(json: parameterJson)
                    else { continue }
                    parameters.append(parameter)
                }

                break
            }
        }

        isFullVersion = true
    }
}
