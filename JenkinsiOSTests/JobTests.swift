//
//  JobTests.swift
//  JenkinsiOS
//
//  Created by Robert on 18.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

@testable import JenkinsiOS
import XCTest

class JobTests: XCTestCase {
    
    /// Test that a Job initializes properly from a minimal version json file
    func testMinimalVersionInitializesProperly(){
        
        guard let json = jsonForResource(name: "JobTestsMinimalResource", extension: "json", type: type(of: self)) as? [String: AnyObject]
            else { XCTFail("Could not get json"); return }
        
        let job = Job(json: json, minimalVersion: true)
        
        XCTAssertNotNil(job)
        
        XCTAssertEqual(job?.name, json["name"] as? String)
        XCTAssertEqual(job?.url, URL(string: json["url"] as! String))
        XCTAssertEqual(job?.color, JenkinsColor(rawValue: json["color"] as! String))
        XCTAssertEqual(job?.isFullVersion, false)
        // We expect all other data (such as the last build) to be nil
        AssertEmpty(job!.builds)
        XCTAssertNil(job?.lastBuild)
    }
    
    func testFullVersionInitializesProperly(){
        guard let json = jsonForResource(name: "JobTestsFullResource", extension: "json", type: type(of: self)) as? [String: AnyObject]
            else { XCTFail("Could not get json"); return }
        guard let job = Job(json: json)
            else { XCTFail("Could not initialize Job"); return }
        
        XCTAssertEqual(job.name, json["name"] as? String)
        XCTAssertEqual(job.url, URL(string: json["url"] as! String))
        XCTAssertEqual(job.color, JenkinsColor(rawValue: json["color"] as! String))
        XCTAssertEqual(job.isFullVersion, true)
        XCTAssertEqual(job.buildable, json["buildable"] as? Bool)
        XCTAssertEqual(job.description, json["description"] as? String)
        XCTAssertEqual(job.inQueue, json["inQueue"] as? Bool)
        XCTAssertEqual(job.description, json["description"] as? String)
        XCTAssertEqual(job.nextBuildNumber, json["nextBuildNumber"] as? Int)
        XCTAssertEqual(job.builds.count, (json["builds"] as? [[String: AnyObject]])?.count ?? -1, "\(json["builds"]) does not have the same length as \(job.builds)")
        
        dump(json)
        
        XCTAssertNotNil(job.firstBuild)
        XCTAssertNotNil(job.lastBuild)
        XCTAssertNotNil(job.lastCompletedBuild)
        XCTAssertNil(job.lastFailedBuild)
        XCTAssertNotNil(job.lastUnsuccessfulBuild)
        XCTAssertNotNil(job.lastStableBuild)
        XCTAssertNotNil(job.lastUnstableBuild)
    }
}
