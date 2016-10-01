//
//  Case.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Case{
    var age: Int?
    var className: String?
    var duration: Double?
    var errorDetails: String?
    var errorStackTrace: String?
    var failedSince: Int?
    var name: String?
    var skipped: Bool?
    var skippedMessage: String?
    var status: String?
    var stdout: String?
    var stderr: String?
    var reportUrl: URL?
    
    init?(json: [String: AnyObject]){
        age = json[Constants.JSON.age] as? Int
        className = json[Constants.JSON.className] as? String
        duration = json[Constants.JSON.duration] as? Double
        errorDetails = json[Constants.JSON.errorDetails] as? String
        errorStackTrace = json[Constants.JSON.errorStackTrace] as? String
        failedSince = json[Constants.JSON.failedSince] as? Int
        name = json[Constants.JSON.name] as? String
        skipped = json[Constants.JSON.skipped] as? Bool
        skippedMessage = json[Constants.JSON.skippedMessage] as? String
        status = json[Constants.JSON.status] as? String
        stdout = json[Constants.JSON.stdout] as? String
        stderr = json[Constants.JSON.stderr] as? String
        
        if let reportUrlString = json[Constants.JSON.reportUrl] as? String{
            reportUrl = URL(string: reportUrlString)
        }
    }
}
