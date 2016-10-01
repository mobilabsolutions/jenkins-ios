//
//  TestResult.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class TestResult{
    
    var failCount: Int?
    var skipCount: Int?
    var totalCount: Int?
    var passCount: Int?
    var urlName: String?
    var childReports: [ChildReport] = []
    var suites: [Suite] = []
    
    
    init?(json: [String: AnyObject]){
        failCount = json[Constants.JSON.failCount] as? Int
        skipCount = json[Constants.JSON.skipCount] as? Int
        totalCount = json[Constants.JSON.totalCount] as? Int
        passCount = json[Constants.JSON.passCount] as? Int
        urlName = json[Constants.JSON.urlName] as? String
        
        if let childReportsJson = json[Constants.JSON.childReports] as? [[String: AnyObject]]{
            for childReportJson in childReportsJson{
                if let childReport = ChildReport(json: childReportJson){
                    childReports.append(childReport)
                }
            }
        }
        
        if let suitesJson = json[Constants.JSON.suites] as? [[String: AnyObject]]{
            for suiteJson in suitesJson{
                if let suite = Suite(json: suiteJson){
                    suites.append(suite)
                }
            }
        }
    }
}
