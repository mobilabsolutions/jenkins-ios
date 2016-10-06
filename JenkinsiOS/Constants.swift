//
//  Constants.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    struct Defaults{
        /// The default port that should be used. 443 because the default protocol is https
        static let defaultPort = 443
    }
    
    struct Paths{
        static let userPath = PersistenceUtils.getDocumentDirectory()!.appendingPathComponent("User")
        static let accountsPath = PersistenceUtils.getDocumentDirectory()!.appendingPathComponent("Account")
    }
    
    struct Identifiers{
        static let accountCell = "accountCell"
        static let jobCell = "jobCell"
        static let buildCell = "buildCell"
        
        static let showJobsSegue = "showJobsSegue"
        static let showJobSegue = "showJobSegue"
        static let showBuildsSegue = "showBuildsSegue"
        static let showBuildSegue = "showBuildSegue"
    }
    
    struct JSON {
        static let allViews = "All"
        static let views = "views"
        static let name = "name"
        static let url = "url"
        static let jobs = "jobs"
        static let color = "color"
        static let builds = "builds"
        static let firstBuild = "firstBuild"
        static let absoluteUrl = "absoluteUrl"
        static let fullName = "fullName"
        static let blocked = "blocked"
        static let buildable = "buildable"
        static let id = "id"
        static let inQueueSince = "inQueueSince"
        static let params = "params"
        static let stuck = "stuck"
        static let why = "why"
        static let task = "task"
        static let buildableStartMilliseconds = "buildableStartMilliseconds"
        static let actions = "actions"
        static let items = "items"
        static let age = "age"
        static let className = "className"
        static let duration = "duration"
        static let errorDetails = "errorDetails"
        static let errorStackTrace = "errorStackTrace"
        static let failedSince = "failedSince"
        static let skipped = "skipped"
        static let skippedMessage = "skippedMessage"
        static let status = "status"
        static let stdout = "stdout"
        static let stderr = "stderr"
        static let reportUrl = "reportUrl"
        static let cases = "cases"
        static let timestamp = "timestamp"
        static let number = "number"
        static let empty = "empty"
        static let failCount = "failCount"
        static let passCount = "passCount"
        static let skipCount = "skipCount"
        static let suites = "suites"
        static let child = "child"
        static let result = "result"
        static let totalCount = "totalCount"
        static let childReports = "childReports"
        static let urlName = "urlName"
        static let active = "active"
        static let shortName = "shortName"
        static let bundled = "bundled"
        static let deleted = "deleted"
        static let downgradable = "downgradable"
        static let enabled = "enabled"
        static let hasUpdate = "hasUpdate"
        static let longName = "longName"
        static let pinned = "pinned"
        static let supportsDynamicLoad = "supportsDynamicLoad"
        static let version = "version"
        static let dependencies = "dependencies"
        static let optional = "optional"
        static let plugins = "plugins"
    }
    
    struct API{
        static let consoleOutput = "/logText/progressiveHtml"
        static let consoleOutputQueryItems = [
            URLQueryItem(name: "start", value: "0")
        ]
        static let jobListAdditionalQueryItems = [
            URLQueryItem(name: "tree", value: "views[name,url,jobs[name,url,color]]")
        ]
        static let testReport = "/testReport"
        static let testReportAdditionalQueryItems = [
            URLQueryItem(name: "tree", value: "suites[name,cases[className,name,status]],childReports[child[url],result[suites[name,cases[className,name,status]],failCount,passCount,skipCount]],failCount,skipCount,passCount,totalCount")
        ]
        static let buildQueue = "/queue"
        static let computer = "/computer"
    }
    
    struct Colors{
        static let jenkinsColors: [JenkinsColor: UIColor] = [
            JenkinsColor.blue: UIColor.blue,
            JenkinsColor.red: UIColor.red,
            JenkinsColor.yellow: UIColor.yellow,
            JenkinsColor.disabled: UIColor.lightGray,
            JenkinsColor.aborted: UIColor.darkGray,
            JenkinsColor.notBuilt: UIColor.orange
        ]
    }
}
