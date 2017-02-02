//
//  NetworkManagerTests.swift
//  JenkinsiOS
//
//  Created by Robert on 10.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class NetworkManagerAuxiliaryTests: XCTestCase {
    
    func testUrlRequestAreCorrectlyCreatedWithAPIUrl(){
        let userRequest = getGenericUserRequest()
        let urlRequest = NetworkManager.manager.urlRequest(for: userRequest, useAPIURL: true, method: .GET)
        
        XCTAssertEqual(urlRequest.url, URL(string: "https://www.test.com/test/api/json?pretty=false")!)
        XCTAssertEqual(urlRequest.httpMethod, "GET")
    }
    
    func testUrlRequestAreCorrectlyCreatedWithoutAPIUrl(){
        let userRequest = getGenericUserRequest()
        let urlRequest = NetworkManager.manager.urlRequest(for: userRequest, useAPIURL: false, method: .GET)
        
        XCTAssertEqual(urlRequest.url, URL(string: "https://www.test.com/test")!)
        XCTAssertEqual(urlRequest.httpMethod, "GET")
    }
    
    func testConsoleOutputUrlIsGeneratedCorrectly(){
        let account = getGenericAccount()
        guard let build = Build(json: [
            "url" : "\(account.baseUrl)/test-build" as AnyObject,
            "number" : 11 as AnyObject
            ], minimalVersion: true)
            else { XCTFail("Could not initialise build"); return }
        let urlRequest = NetworkManager.manager.getConsoleOutputUserRequest(build: build, account: account)
        XCTAssertEqual(urlRequest.url, URL(string: "\(build.url)/consoleText"))
    }
    
    //MARK: - Helpers
    private func getGenericUserRequest() -> UserRequest{
        let account = getGenericAccount()
        return UserRequest(requestUrl: URL(string: "https://www.test.com/test")!, account: account)
    }
    
    private func getGenericAccount() -> Account{
        return Account(baseUrl: URL(string: "https://www.test.com")!, username: nil, password: nil, port: nil, displayName: nil)
    }
}
