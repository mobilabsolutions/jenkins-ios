//
//  UserRequestTests.swift
//  JenkinsiOS
//
//  Created by Robert on 12.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class UserRequestTests: ModelTestCase {
    
    private var url: URL!
    private var account: Account!
    
    override func setUp() {
        url = getGenericURL()
        account = getGenericAccount(for: url)
    }
    
    func testInitializesProperly(){
        let userRequest = UserRequest(requestUrl: url, account: account)
        
        assureValuesAreExpected(values: [
            (userRequest.apiURL, URL(string: "https://www.test-url.test:8080/api/json?pretty=false")!),
            (userRequest.requestUrl, url.using(scheme: "https", at: 8080)),
            (userRequest.account, account)
        ])
    }
    
    func testInitializesProperlyWithAdditionalQueryItems(){
        let userRequest = UserRequest(requestUrl: url, account: account, additionalQueryItems: [
                URLQueryItem(name: "item", value: "value")
            ])
        
        assureValuesAreExpected(values: [
            (userRequest.apiURL, URL(string: "https://www.test-url.test:8080/api/json?pretty=false&item=value")!),
            (userRequest.requestUrl, url.using(scheme: "https", at: 8080)),
            (userRequest.account, account)
        ])
    }
    
    func testUserRequestForPlugins(){
        let userRequest = UserRequest.userRequestForPlugins(account: account)
        
        assureValuesAreExpected(values: [
            (userRequest.apiURL, URL(string: "https://www.test-url.test:8080/pluginManager/api/json?pretty=false&depth=2")!),
            (userRequest.requestUrl, url.using(scheme: "https", at: 8080)?.appendingPathComponent("pluginManager")),
            (userRequest.account, account)
        ])
    }
    
    func testUserRequestForComputers(){
        let userRequest = UserRequest.userRequestForComputers(account: account)
        
        assureValuesAreExpected(values: [
            (userRequest.apiURL, URL(string: "https://www.test-url.test:8080/computer/api/json?pretty=false")!),
            (userRequest.requestUrl, url.using(scheme: "https", at: 8080)?.appendingPathComponent("computer")),
            (userRequest.account, account)
            ])
    }
    
    func testUserRequestForUsers(){
        let userRequest = UserRequest.userRequestForUsers(account: account)
        
        assureValuesAreExpected(values: [
            (userRequest.apiURL, URL(string: "https://www.test-url.test:8080/asynchPeople/api/json?pretty=false")!),
            (userRequest.requestUrl, url.using(scheme: "https", at: 8080)?.appendingPathComponent("asynchPeople")),
            (userRequest.account, account)
        ])
    }
    
    func testUserRequestForJobList(){
        let userRequest = UserRequest.userRequestForJobList(account: account)
        
        assureValuesAreExpected(values: [
            (userRequest.apiURL, URL(string: "https://www.test-url.test:8080/api/json?pretty=false&tree=" + Constants.API.jobListAdditionalQueryItems.first!.value!)!),
            (userRequest.requestUrl, url.using(scheme: "https", at: 8080)),
            (userRequest.account, account)
        ])
    }
    
    func testUserRequestForBuildQueue(){
        let userRequest = UserRequest.userRequestForBuildQueue(account: account)
        
        assureValuesAreExpected(values: [
            (userRequest.apiURL, URL(string: "https://www.test-url.test:8080/queue/api/json?pretty=false")!),
            (userRequest.requestUrl, url.using(scheme: "https", at: 8080)?.appendingPathComponent("queue")),
            (userRequest.account, account)
        ])
    }
    
    private func getGenericAccount(for url: URL) -> Account{
        return Account(baseUrl: url, username: "Username", password: "Password", port: 8080, displayName: nil)
    }
    
    private func getGenericURL() -> URL{
        return URL(string: "https://www.test-url.test")!
    }
}
