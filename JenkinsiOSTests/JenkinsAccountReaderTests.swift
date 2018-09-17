//
//  JenkinsAccountReaderTests.swift
//  JenkinsiOS
//
//  Created by Robert on 27.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class JenkinsAccountReaderTests: XCTestCase {
    func testParsesAccountCorrectly() {
        let account = JenkinsAccountReader.getAccount(for: type(of: self), with: "JenkinsTest")

        XCTAssertNotNil(account)
        XCTAssertEqual(account?.baseUrl, URL(string: "YOUR_JENKINS_URL_HERE"))
        XCTAssertEqual(account?.username, "YOUR JENKINS USERNAME HERE")
        XCTAssertEqual(account?.password, "YOUR JENKINS API-KEY HERE")
        XCTAssertEqual(account?.port, 443)
    }
}
