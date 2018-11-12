//
//  JobTests.swift
//  JenkinsiOS
//
//  Created by Robert on 18.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

@testable import JenkinsiOS
import XCTest

class JobTests: ModelTestCase {
    /// Test that a Job initializes properly from a minimal version json file
    func testMinimalVersionInitializesProperly() {
        guard let json = jsonForResource(name: "JobTestsMinimalResource", extension: "json", type: type(of: self)) as? [String: Any]
        else { XCTFail("Could not get json"); return }

        guard let job = Job(json: json as [String: AnyObject], minimalVersion: true)
        else { XCTFail("Could not initialize Job"); return }

        assureValuesAreExpected(values: [
            (job.name, json["name"]),
            (job.url, URL(string: json["url"] as! String)),
            (job.color, JenkinsColor(rawValue: json["color"] as! String)),
            (job.isFullVersion, false),
            (job.builds, []),
            (job.lastBuild, nil),
        ])
    }

    func testFullVersionInitializesProperly() {
        guard let json = jsonForResource(name: "JobTestsFullResource", extension: "json", type: type(of: self)) as? [String: Any]
        else { XCTFail("Could not get json"); return }
        guard let job = Job(json: json as [String: AnyObject])
        else { XCTFail("Could not initialize Job"); return }

        var values: [(Any?, Any?)] = [
            (job.name, json["name"]),
            (job.url, URL(string: json["url"] as! String)),
            (job.color, JenkinsColor(rawValue: json["color"] as! String)),
            (job.isFullVersion, true),
        ]

        assureValuesAreExpected(values: values)

        values = [
            (job.buildable, json["buildable"]),
            (job.description, json["description"]),
            (job.inQueue, json["inQueue"]),
            (job.description, json["description"]),
            (job.nextBuildNumber, json["nextBuildNumber"]),
            (job.lastFailedBuild, nil),
        ]

        assureValuesAreExpected(values: values)

        XCTAssertNotNil(job.firstBuild)
        XCTAssertNotNil(job.lastBuild)
        XCTAssertNotNil(job.lastCompletedBuild)
        XCTAssertNotNil(job.lastUnsuccessfulBuild)
        XCTAssertNotNil(job.lastStableBuild)
        XCTAssertNotNil(job.lastUnstableBuild)
        XCTAssertTrue(job.parameters.count == 1)
    }
}
