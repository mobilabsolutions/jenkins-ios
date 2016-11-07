//
// Created by Robert on 27.10.16.
// Copyright (c) 2016 MobiLab Solutions. All rights reserved.
//

@testable import JenkinsiOS
import XCTest

class BuildTest: ModelTestCase {

    func testMinimalInitializesProperly(){
        guard let json = jsonForResource(name: "BuildTestsMinimalResource", extension: "json", type: type(of: self)) as? [String: AnyObject]
            else { XCTFail("Could not properly get JSON"); return }
        let build = Build(json: json, minimalVersion: true)
        
        XCTAssertEqual(build?.number, 122)
        XCTAssertEqual(build?.url, URL(string: "https://builds.apache.org/job/Accumulo-1.8/122/"))
        
        //Most attributes should be nil
        XCTAssertNil(build?.buildDescription)
        XCTAssertNil(build?.building)
        XCTAssertNil(build?.actions)
        XCTAssertNil(build?.builtOn)
    }

}
