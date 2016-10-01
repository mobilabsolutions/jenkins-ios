//
//  Suite.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Suite{
    
    var cases: [Case] = []
    var duration: Double
    var id: String
    var name: String?
    var stderr: String?
    var stdout: String?
    var timestamp: String?
    
    init?(json: [String: AnyObject]){
        guard let duration = json[Constants.JSON.duration] as? Double,
              let id = json[Constants.JSON.id] as? String
            else { return nil }
        self.duration = duration
        self.id = id
        
        name = json[Constants.JSON.name] as? String
        stderr = json[Constants.JSON.stderr] as? String
        stdout = json[Constants.JSON.stdout] as? String
        timestamp = json[Constants.JSON.timestamp] as? String
        
        if let casesJson = json[Constants.JSON.cases] as? [[String: AnyObject]]{
            for caseJson in casesJson{
                if let parsedCase = Case(json: caseJson){
                    cases.append(parsedCase)
                }
            }
        }
    }
    
}
