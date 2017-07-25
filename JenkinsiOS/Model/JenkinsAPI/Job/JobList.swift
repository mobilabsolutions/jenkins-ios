//
//  JobList.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class JobList{
    
    /// The view corresponding to all jobs
    var allJobsView: View?
    /// The list of all views in the job
    var views: [View] = []
    
    /// The description of the Job List
    var description: String?
    /// The description of the executing node
    var nodeDescription: String?
    /// The current mode in which the job list is executed
    var mode: String?
    /// The node's name
    var nodeName: String?
    
    /// Initialize a JobList object
    ///
    /// - parameter json: The json from which to initialize the JobList
    ///
    /// - returns: An initialized JobList object
    init(json: [String: AnyObject]) throws{
        guard let viewsJson = json[Constants.JSON.views] as? [[String: AnyObject]]
            else { throw ParsingError.KeyMissingError(key: Constants.JSON.views) }
        
        for viewJson in viewsJson{
            if let view = View(json: viewJson){
                views.append(view)
                
                if view.name == Constants.JSON.allViews{
                    allJobsView = view
                }
            }
        }
        
        description = json[Constants.JSON.description] as? String
        nodeDescription = json[Constants.JSON.nodeDescription] as? String
        mode = json[Constants.JSON.mode] as? String
        nodeName = json[Constants.JSON.nodeName] as? String
        
    }
}
