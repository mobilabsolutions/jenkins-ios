//
//  AccountManagerTests.swift
//  JenkinsiOS
//
//  Created by Robert on 12.11.16.
//  Copyright (c) 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class AccountManagerTests: XCTestCase {
    private var removedAccounts: [Account] = []

    override func setUp() {
        super.setUp()
        AccountManager.manager.accounts.forEach {
            account in
            _ = try? AccountManager.manager.deleteAccount(account: account)
            self.removedAccounts.append(account)
        }
    }

    override func tearDown() {
        super.tearDown()

        removedAccounts.forEach {
            account in
            _ = try? AccountManager.manager.addAccount(account: account)
        }

        removedAccounts = []
    }

    func testAddsAccountProperly() {
        let accounts = addGenericAccounts()
        assertAccountsAreEqualWith(accounts: accounts)
    }

    func testUpdatesProperly() {
        let accounts = addGenericAccounts()
        AccountManager.manager.accounts = []
        AccountManager.manager.update()
        assertAccountsAreEqualWith(accounts: accounts)
    }

    func testDeletesProperly() {
        var accounts = addGenericAccounts()
        do {
            try AccountManager.manager.deleteAccount(account: accounts.first!)
            _ = accounts.removeFirst()
            assertAccountsAreEqualWith(accounts: accounts)
            AccountManager.manager.accounts = []
            AccountManager.manager.update()
            assertAccountsAreEqualWith(accounts: accounts)
        } catch {
            XCTFail("Should be able to delete account: \(accounts.first!)")
        }
    }

    func testSavesProperly() {
        _ = addGenericAccounts()

        let url = AccountManager.manager.accounts.first!.baseUrl
        AccountManager.manager.accounts.first!.username = "OtherUsernameThanBefore"
        AccountManager.manager.save()

        AccountManager.manager.accounts = []
        AccountManager.manager.update()
        let changed = AccountManager.manager.accounts.first { $0.baseUrl == url }?.username == "OtherUsernameThanBefore"
        XCTAssertTrue(changed, "The username should have changed")
    }

    private func addGenericAccounts() -> [Account] {
        let accounts = [
            getGenericAccount(with: "test1"),
            getGenericAccount(with: "test2"),
        ]

        accounts.forEach {
            _ = try? AccountManager.manager.addAccount(account: $0)
        }

        return accounts
    }

    private func assertAccountsAreEqualWith(accounts: [Account]) {
        guard accounts.count == AccountManager.manager.accounts.count
        else { XCTFail("There should be an equal number of accounts! Instead: given \(accounts.count)" +
                " wanted: \(AccountManager.manager.accounts.count)"); return }

        for (index, account) in AccountManager.manager.accounts.enumerated() {
            XCTAssertTrue(account.isEqual(accounts[index]))
        }
    }

    private func getGenericURL(with pathComponent: String) -> URL {
        return URL(string: "https://www.test.com")!.appendingPathComponent(pathComponent)
    }

    private func getGenericAccount(with pathComponent: String) -> Account {
        return Account(baseUrl: getGenericURL(with: pathComponent),
                       username: nil, password: nil, port: nil, displayName: nil)
    }
}
