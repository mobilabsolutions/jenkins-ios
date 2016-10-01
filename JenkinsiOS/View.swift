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
    var jobs: [Job] = []
    
    var description: String{
        return "View \"\(name)\""
    }
    
    init?(json: [String: AnyObject]){
        guard let name = json[Constants.JSON.name] as? String, let urlString = json[Constants.JSON.url] as? String,
            let url = URL(string: urlString)
            else { return nil }
        self.name = name
        self.url = url
        
        if let jobsJson = json[Constants.JSON.jobs] as? [[String: AnyObject]]{
            for jobJson in jobsJson{
                if let job = Job(json: jobJson, minimalVersion: true){
                    jobs.append(job)
                }
            }
        }
        
    }
}
