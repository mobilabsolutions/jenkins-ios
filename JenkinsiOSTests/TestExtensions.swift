//
//  TestExtensions.swift
//  JenkinsiOS
//
//  Created by Robert on 18.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation
import XCTest

func AssertEmpty<T>(_ value: [T]){
    XCTAssertTrue(value.isEmpty)
}

func AssertNotEmpty<T>(_ value: [T]){
    XCTAssertFalse(value.isEmpty)
}

func jsonForResource(name: String, extension fileExtension: String?, type: AnyClass) -> Any?{
    guard let url = Bundle(for: type).url(forResource: "JobTestsMinimalResource", withExtension: fileExtension)
        else { XCTFail("Bundle URL could not be found"); return nil }
    guard let data = try? Data(contentsOf: url)
        else { XCTFail("Could not get data for resource file"); return nil }
    guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        else { XCTFail("Could not get json in correct format"); return nil }
    return json
}
