//
//  TestResult.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class TestResult{
    
    /// The number of failed tests
    var failCount: Int?
    /// The total number of skipped tests
    var skipCount: Int?
    /// The total number of tests
    var totalCount: Int?
    /// The number of passed tests
    var passCount: Int?
    /// The name of the url
    var urlName: String?
    /// The childreports corresponding to the given test results. Generally either this or suites is empty, but not both at once.
    var childReports: [ChildReport] = []
    /// The suites corresponding to the given test results. Generally either this or childReports is empty, but not both at once.
    var suites: [Suite] = []
    
    /// Initialize a Test Result
    ///
    /// - parameter json: The json from which to initialize the test result
    ///
    /// - returns: A TestResult object or nil, if the initialization failed
    init(json: [String: AnyObject]){
        failCount = json[Constants.JSON.failCount] as? Int
        skipCount = json[Constants.JSON.skipCount] as? Int
        totalCount = json[Constants.JSON.totalCount] as? Int
        passCount = json[Constants.JSON.passCount] as? Int
        urlName = json[Constants.JSON.urlName] as? String
        
        if passCount == nil, let failCount = failCount, let skipCount = skipCount, let totalCount = totalCount{
            passCount = totalCount - (failCount + skipCount)
        }
        
        if let childReportsJson = json[Constants.JSON.childReports] as? [[String: AnyObject]]{
            for childReportJson in childReportsJson{
                childReports.append(ChildReport(json: childReportJson))
            }
        }
        else if let suitesJson = json[Constants.JSON.suites] as? [[String: AnyObject]]{
            for suiteJson in suitesJson{
                if let suite = Suite(json: suiteJson){
                    suites.append(suite)
                }
            }
        }
    }
}
