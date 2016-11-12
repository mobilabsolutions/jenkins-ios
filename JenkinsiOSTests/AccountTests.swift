//
//  AccountTests.swift
//  JenkinsiOS
//
//  Created by Robert on 12.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class AccountTests: ModelTestCase {
    
    func testInitializesCorrectly(){
        let account = Account(baseUrl: URL(string: "http://www.test.com")!, username: "Username", password: "Password", port: 2000, displayName: "TestDisplayName")
        
        assureValuesAreExpected(values: [
            (account.baseUrl, URL(string: "http://www.test.com")!),
            (account.username, "Username"),
            (account.password, "Password"),
            (account.port, 2000),
            (account.displayName, "TestDisplayName")
        ])
    }
    
    func testInitializesCorrectlyFromCoder(){
        let account = Account(baseUrl: URL(string: "http://www.test.com")!, username: "Username", password: "Password", port: 2000, displayName: "TestDisplayName")
        
        let data = encode(account: account)
        
        let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? Account
        
        XCTAssertNotNil(object)
        
        assureValuesAreExpected(values: [
            (object?.baseUrl, account.baseUrl),
            (object?.port, account.port),
            (object?.username, account.username),
            (object?.displayName, account.displayName)
        ])
    }
    
    private func encode(account: Account) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: account)
    }
}
