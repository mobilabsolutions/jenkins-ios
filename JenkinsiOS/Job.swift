//
//  Job.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Job: Favoratible{
    
    //MARK: - Minimal Version
    var name: String
    var url: URL
    var color: JenkinsColor?
    
    //MARK: - Full version
    //TODO: Implement all fields
    var description: String?
    
    var buildable: Bool?
    var builds: [Build]?
    
    var healthReport: [HealthReportResult]?
    var inQueue: Bool?
    var keepDependencies: Bool?
    
    var firstBuild: Build?
    var lastBuild: Build?
    var lastCompletedBuild: Build?
    var lastFailedBuild: Build?
    var lastStableBuild: Build?
    var lastSuccessfulBuild: Build?
    var lastUnstableBuild: Build?
    var lastUnsuccessfulBuild: Build?

    var nextbuildNumber: Int?
    
    /// Is the job information based on "full version" JSON?
    var isFullVersion = false
    
    init?(json: [String: AnyObject], minimalVersion: Bool = false){
        guard let name = json[Constants.JSON.name] as? String, let urlString = json[Constants.JSON.url] as? String
            else { return nil }
        guard let url = URL(string: urlString)
            else { return nil }
        
        if let stringColor = json["color"] as? String{
            self.color = JenkinsColor(rawValue: stringColor)
        }
        
        self.url = url
        self.name = name
        
        // The minimal version only contains these select fields
        if !minimalVersion{
            addAdditionalFields(from: json)
        }
        

    }
    
    /// Add values for fields in the full job category
    ///
    /// - parameter json: The JSON parsed data from which to get the values for the additional fields
    func addAdditionalFields(from json: [String: AnyObject]){
        
        if let stringColor = json["color"] as? String{
            self.color = JenkinsColor(rawValue: stringColor)
        }
        
        description = json["description"] as? String
        buildable = json["buildable"] as? Bool
        builds = (json["builds"] as? [[String: AnyObject]])?.map{ Build(json: $0) }.filter{ $0 != nil }.map{ $0! }
        healthReport = (json["healthReport"] as? [[String: AnyObject]])?.map{ HealthReportResult(json: $0) }.filter{ $0 != nil }.map{ $0! }
        inQueue = json["inQueue"] as? Bool
        keepDependencies =  json["keepDependencies"] as? Bool
        
        // Get the interesting builds from the json data and, if they can be converted to a dictionary, try to initialize a Build from them
        firstBuild = json["firstBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["firstBuild"] as! [String: AnyObject])
        lastBuild = json["lastBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastBuild"] as! [String: AnyObject])
        lastCompletedBuild = json["lastCompletedBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastCompletedBuild"] as! [String: AnyObject])
        lastFailedBuild = json["lastFailedBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastFailedBuild"] as! [String: AnyObject])
        lastStableBuild = json["lastStableBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastStableBuild"] as! [String: AnyObject])
        lastSuccessfulBuild = json["lastSuccessfulBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastSuccessfulBuild"] as! [String: AnyObject])
        lastUnstableBuild = json["lastUnstableBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastUnstableBuild"] as! [String: AnyObject])
        lastUnsuccessfulBuild = json["lastUnsuccessfulBuild"] as? [String: AnyObject] == nil ? nil : Build(json: json["lastUnsuccessfulBuild"] as! [String: AnyObject])
        
        nextbuildNumber = json["nextBuildNumber"] as? Int
        
        isFullVersion = true
    }
}
