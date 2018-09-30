//
//  SearchableTests.swift
//  JenkinsiOS
//
//  Created by Robert on 10.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class SearchableTests: XCTestCase {
    func testInitializesProperly() {
        let searchable = Searchable(searchString: "TestString", data: "This is data" as AnyObject, action: {})
        XCTAssertEqual(searchable.searchString, "TestString")
        XCTAssertEqual(searchable.data as? NSObject, "This is data" as NSObject)
        XCTAssertEqual(searchable.lowerCasedSearchString, "teststring")
    }
}
