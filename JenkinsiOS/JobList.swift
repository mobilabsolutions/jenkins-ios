//
//  JobList.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class JobList: CustomStringConvertible{
    
    var jobs: [Job] = []
    var views: [View]?
    
    //FIXME: Init with different tree
    init(data: Any) throws{
        guard let json = data as? [String: AnyObject]
            else { throw ParsingError.DataNotCorrectFormatError }
        guard let jsonJobs = json["jobs"] as? [[String: AnyObject]]
            else{ throw ParsingError.KeyMissingError(key: "jobs") }
        
        for jsonJob in jsonJobs{
            if let job = Job(json: jsonJob, minimalVersion: true){
                jobs.append(job)
            }
        }
        
        if let jsonViews = json["views"] as? [[String: AnyObject]]{
            views = []
            for jsonView in jsonViews{
                if let view = View(json: jsonView){
                    views?.append(view)
                }
            }
        }
    }
    
    var description: String{
        return "{\n" + jobs.reduce("", { (result, job) -> String in
            return "\(result) Name: \(job.name), Description: \(job.description) \n"
        }) + (views?.reduce("Views: ", { (result, view) -> String in
            return "\(result)\(view)\n"
        }) ?? "No views") + "}"
    }
}
