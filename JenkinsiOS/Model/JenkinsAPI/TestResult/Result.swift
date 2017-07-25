//
//  Result.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Result{
    /// The duration it took for the tests to run
    var duration: Double
    /// Whether or not the result is empty
    var empty: Bool?
    /// The number of failed tests for the given Result
    var failCount: Int
    /// The number of passed tests for the given Result
    var passCount: Int
    /// The number of skipped tests for the given Result
    var skipCount: Int
    /// The suites in the given Result
    var suites: [Suite] = []
    
    /// Optionally initialize a Result
    ///
    /// - parameter json: The json from which to initialize the result
    ///
    /// - returns: A result object or nil, if initialization failed
    init?(json: [String: AnyObject]){
        guard let duration = json[Constants.JSON.duration] as? Double,
              let failCount = json[Constants.JSON.failCount] as? Int,
              let passCount = json[Constants.JSON.passCount] as? Int,
              let skipCount = json[Constants.JSON.skipCount] as? Int
            else { return nil }
        
        self.duration = duration
        self.failCount = failCount
        self.passCount = passCount
        self.skipCount = skipCount
        
        empty = json[Constants.JSON.empty] as? Bool
        
        if let suitesJson = json[Constants.JSON.suites] as? [[String: AnyObject]]{
            for suiteJson in suitesJson{
                if let suite = Suite(json: suiteJson){
                    suites.append(suite)
                }
            }
        }
    }
}
