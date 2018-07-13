//
//  JobListResult.swift
//  JenkinsiOS
//
//  Created by Robert on 27.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

enum JobListResult{
    case job(job: Job)
    case folder(folder: Job)
    
    init?(json: [String: AnyObject]){
        guard let job = Job(json: json, minimalVersion: true)
            else { return nil }
        
        if job.color == .folder {
            self = JobListResult.folder(folder: job)
        }
        else{
            self = JobListResult.job(job: job)
        }
    }
    
    var data: Job{
        switch self{
            case .job(let job): return job
            case .folder(let folder): return folder
        }
    }
    
    var name: String{
        return data.name
    }
    
    var url: URL{
        return data.url
    }
    
    var color: JenkinsColor?{
        return data.color
    }
    
    var description: String?{
        return data.description
    }
}
