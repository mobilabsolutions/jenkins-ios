//
//  ApplicationUserManagerTests.swift
//  JenkinsiOS
//
//  Created by Robert on 12.11.16.
//  Copyright (c) 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class ApplicationUserManagerTests: XCTestCase {
    private var favorites: [Favorite] = []

    override func setUp() {
        super.setUp()
        favorites = ApplicationUserManager.manager.applicationUser.favorites
        ApplicationUserManager.manager.applicationUser.favorites = []
        ApplicationUserManager.manager.save()
    }

    override func tearDown() {
        super.tearDown()
        ApplicationUserManager.manager.applicationUser.favorites = favorites
        ApplicationUserManager.manager.save()
    }

    func testUpdatesProperly() {
        ApplicationUserManager.manager.applicationUser.favorites = [
            Favorite(url: getGenericURL(), type: .job, account: getGenericAccount()),
        ]
        ApplicationUserManager.manager.update()

        XCTAssertEqual(ApplicationUserManager.manager.applicationUser.favorites.count, 0)
    }

    func testSavesProperly() {
        let favorite = Favorite(url: getGenericURL(), type: .job, account: getGenericAccount())
        ApplicationUserManager.manager.applicationUser.favorites = [favorite]

        ApplicationUserManager.manager.save()
        ApplicationUserManager.manager.applicationUser.favorites = []
        ApplicationUserManager.manager.update()

        XCTAssertEqual(ApplicationUserManager.manager.applicationUser.favorites.count, 1)
        XCTAssertTrue(ApplicationUserManager.manager.applicationUser.favorites.first!.isEqual(favorite))
    }

    private func getGenericURL() -> URL {
        return URL(string: "https://www.test.test")!
    }

    private func getGenericAccount() -> Account {
        return Account(baseUrl: getGenericURL(), username: nil, password: nil, port: nil, displayName: nil)
    }
}
