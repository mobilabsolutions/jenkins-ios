//
// Created by Robert on 27.10.16.
// Copyright (c) 2016 MobiLab Solutions. All rights reserved.
//

@testable import JenkinsiOS
import XCTest

class BuildTest: ModelTestCase {
    func testMinimalInitializesProperly() {
        guard let json = jsonForResource(name: "BuildTestsMinimalResource", extension: "json", type: type(of: self)) as? [String: AnyObject]
        else { XCTFail("Could not properly get JSON"); return }
        guard let build = Build(json: json, minimalVersion: true)
        else { XCTFail("Build should not be nil"); return }
        assureValuesAreExpected(values: [
            (build.number, json["number"]),
            (build.url, URL(string: json["url"] as! String)),
            (build.buildDescription, nil),
            (build.building, nil),
            (build.actions, nil),
            (build.builtOn, nil),
        ])
    }

    func testFullVersionInitializesProperly() {
        guard let json = jsonForResource(name: "BuildTestsFullResource", extension: "json", type: type(of: self)) as? [String: AnyObject]
        else { XCTFail("Could not properly get JSON"); return }
        guard let build = Build(json: json, minimalVersion: false)
        else { XCTFail("Build should not be nil"); return }

        assureValuesAreExpected(values: [
            (build.number, json["number"]),
            (build.url, URL(string: json["url"] as! String)),
        ])
    }
}
