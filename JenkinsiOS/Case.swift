//
//  Case.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Case{
    
    enum Status: String{
        case passed = "PASSED"
        case skipped = "SKIPPED"
        case failed = "FAILED"
    }
    
    
    /// The age of the test case
    var age: Int?
    /// The name of the class to which the test case belongs
    var className: String?
    /// The duration it took for the test case to run
    var duration: Double?
    /// The test case's error details
    var errorDetails: String?
    /// The test case's error stack trace
    var errorStackTrace: String?
    /// Since when this test case failed
    var failedSince: Int?
    /// The case's name
    var name: String?
    /// Whether or not the case was skipped
    var skipped: Bool?
    /// Why the case was skipped, if so
    var skippedMessage: String?
    /// The case's status
    var status: Status?
    /// The stdout output that the case produced
    var stdout: String?
    /// The stderr output that the case produced
    var stderr: String?
    /// The url of the case's report
    var reportUrl: URL?
    
    /// Initialize a test Case
    ///
    /// - parameter json: The json from which to initialize the test case
    ///
    /// - returns: An initialized test case object
    init(json: [String: AnyObject]){
        age = json[Constants.JSON.age] as? Int
        className = json[Constants.JSON.className] as? String
        duration = json[Constants.JSON.duration] as? Double
        errorDetails = json[Constants.JSON.errorDetails] as? String
        errorStackTrace = json[Constants.JSON.errorStackTrace] as? String
        failedSince = json[Constants.JSON.failedSince] as? Int
        name = json[Constants.JSON.name] as? String
        skipped = json[Constants.JSON.skipped] as? Bool
        skippedMessage = json[Constants.JSON.skippedMessage] as? String
        stdout = json[Constants.JSON.stdout] as? String
        stderr = json[Constants.JSON.stderr] as? String
        
        if let statusString = json[Constants.JSON.status] as? String{
            status = Status(rawValue: statusString)
        }
        
        if let reportUrlString = json[Constants.JSON.reportUrl] as? String{
            reportUrl = URL(string: reportUrlString)
        }
    }
}
