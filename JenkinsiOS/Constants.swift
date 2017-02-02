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
        static let sharedUserPath = PersistenceUtils.getSharedDirectory()?.appendingPathComponent("Storage").appendingPathComponent("User")
        static let accountsPath = PersistenceUtils.getDocumentDirectory()!.appendingPathComponent("Account")
        static let sharedAccountsPath = PersistenceUtils.getSharedDirectory()?.appendingPathComponent("Storage").appendingPathComponent("Account")
    }
    
    struct Config{
        static var keychainAccessGroup: String?{
            guard let dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Config", ofType: "plist")!)
                else { return nil }
            guard let prefix = dict.value(forKey: "App ID Prefix") as? String, let identifier = dict.value(forKey: "Shared Keychain Identifier") as? String
                else { return nil }
            return "\(prefix).\(identifier)"
            
        }
    }
    
    struct UI{
        static let bigButtonColor = UIColor(red: 125/255, green: 151/255, blue: 255/255, alpha: 1.0)
        static let defaultLabelFont = "SourceSansPro"
    }
    
    struct Identifiers{
        static let accountCell = "accountCell"
        static let jobCell = "jobCell"
        static let folderCell = "folderCell"
        static let buildCell = "buildCell"
        static let favoritesCell = "favoritesCell"
        static let jenkinsCell = "jenkinsCell"
        static let staticBuildInfoCell = "staticBuildInfoCell"
        static let longBuildInfoCell = "longBuildInfoCell"
        static let moreInfoBuildCell = "moreInfoBuildCell"
        static let changeCell = "changeCell"
        static let testResultCell = "testResultCell"
        static let testResultErrorDetailsCell = "testResultErrorDetailsCell"
        static let computerCell = "computerCell"
        static let pluginCell = "pluginCell"
        static let userCell = "userCell"
        static let artifactsCell = "artifactsCell"
        static let parameterCell = "parameterCell"
        
        static let showJobsSegue = "showJobsSegue"
        static let showJobSegue = "showJobSegue"
        static let showBuildsSegue = "showBuildsSegue"
        static let showBuildSegue = "showBuildSegue"
        static let showBuildQueueSegue = "showBuildQueueSegue"
        static let showJenkinsSegue = "showJenkinsSegue"
        static let showConsoleOutputSegue = "showConsoleOutputSegue"
        static let showChangesSegue = "showChangesSegue"
        static let showTestResultsSegue = "showTestResultsSegue"
        static let showTestResultSegue = "showTestResultSegue"
        static let showComputersSegue = "showComputersSegue"
        static let showUsersSegue = "showUsersSegue"
        static let showPluginsSegue = "showPluginsSegue"
        static let editAccountSegue = "editAccountSegue"
        static let showArtifactsSegue = "showArtifactsSegue"
        static let showFolderSegue = "showFolderSegue"
        static let showParametersSegue = "showParametersSegue"
        static let didAddAccountSegue = "didAddAccountSegue"
        static let showInformationSegue = "showInformationSegue"
        
        static let favoritesShortcutItemType = "com.mobilabsolutions.favorites.shortcutItem"
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
        static let description = "description"
        static let nodeDescription = "nodeDescription"
        static let mode = "mode"
        static let nodeName = "nodeName"
        static let lastChange = "lastChange"
        static let project = "project"
        static let user = "user"
        static let users = "users"
        static let availablePhysicalMemory = "availablePhysicalMemory"
        static let availableSwapSpace = "availableSwapSpace"
        static let totalPhysicalMemory = "totalPhysicalMemory"
        static let totalSwapSpace = "totalSwapSpace"
        static let artifacts = "artifacts"
        static let fileName = "fileName"
        static let relativePath = "relativePath"
        static let crumb = "crumb"
        static let crumbRequestField = "crumbRequestField"
        static let type = "type"
        static let defaultParameterValue = "defaultParameterValue"
        static let value = "value"
        static let parameterDefinitions = "parameterDefinitions"
        static let property = "property"
        static let choices = "choices"
        static let projectName = "projectName"
    }
    
    struct Networking{
        static let successCodes = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]
    }
    
    struct API{
        static let consoleOutput = "/consoleText"
        static let jobListAdditionalQueryItems = [
            URLQueryItem(name: "tree", value: "views[name,url,jobs[name,url,color]],nodeDescription,nodeName,mode,description")
        ]
        static let testReport = "/testReport"
        static let testReportAdditionalQueryItems = [
            URLQueryItem(name: "tree", value: "suites[name,cases[className,name,status]],childReports[child[url],result[suites[name,cases[className,name,status]],failCount,passCount,skipCount]],failCount,skipCount,passCount,totalCount")
        ]
        static let buildQueue = "/queue"
        static let computer = "/computer"
        static let plugins = "/pluginManager"
        static let pluginsAdditionalQueryItems = [
            URLQueryItem(name: "depth", value: "2")
        ]
        static let users = "/asynchPeople"
        static let artifact = "/artifact"
        static let crumbIssuer = "/crumbIssuer"
        
        static let quietDown = "/quietDown"
        static let cancelQuietDown = "/cancelQuietDown"
        static let restart = "/restart"
        static let safeRestart = "/safeRestart"
    }
}
