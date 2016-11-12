//
//  ApplicationUserTests.swift
//  JenkinsiOS
//
//  Created by Robert on 12.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class ApplicationUserTests: ModelTestCase {
    func testInitializesCorrectly(){
        let applicationUser = ApplicationUser()
        let baseUrl = getGenericURL()
        let account = Account(baseUrl: baseUrl, username: nil, password: nil, port: nil, displayName: nil)
        applicationUser.favorites = [
            Favorite(url: baseUrl.appendingPathComponent("/job/favorite"), type: .job, account: account)
        ]

        let data = NSKeyedArchiver.archivedData(withRootObject: applicationUser)
        let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data) as? ApplicationUser
        
        guard let unarchivedUser = unarchived
            else { XCTFail("Unarchived should not be nil"); return }

        guard unarchivedUser.favorites.count == applicationUser.favorites.count
            else { XCTFail("Unarchived favorites should have the same length as original.\n " +
                "Actually: \(unarchivedUser.favorites.count) / \(applicationUser.favorites.count)"); return}

        for (index, item) in unarchivedUser.favorites.enumerated() {
            XCTAssertTrue(item.isEqual(applicationUser.favorites[index]))
        }
    }

    func getGenericURL() -> URL{
        return URL(string: "https://www.test.test")!
    }
}
