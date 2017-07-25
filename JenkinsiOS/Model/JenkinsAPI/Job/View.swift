//
//  View.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class View: CustomStringConvertible{
    var name: String
    var url: URL
    var jobResults: [JobListResult] = []
    
    var description: String{
        return "View \"\(name)\""
    }
    
    /// Optionally initialize a View object
    ///
    /// - parameter json: The json from which to initialize the View
    ///
    /// - returns: The initialized View object or nil, if initialization failed
    init?(json: [String: AnyObject]){
        guard let name = json[Constants.JSON.name] as? String, let urlString = json[Constants.JSON.url] as? String,
            let url = URL(string: urlString)
            else { return nil }
        self.name = name
        self.url = url
        
        if let jobsJson = json[Constants.JSON.jobs] as? [[String: AnyObject]]{
            for jobJson in jobsJson{
                if let job = JobListResult(json: jobJson){
                    jobResults.append(job)
                }
            }
        }
    }
}
