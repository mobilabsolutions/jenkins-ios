//
//  NetworkManagerTests.swift
//  JenkinsiOS
//
//  Created by Robert on 27.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class NetworkManagerTests: XCTestCase {
    
    var account: Account?
    var manager = NetworkManager.manager
    
    override func setUp() {
        account = JenkinsAccountReader.getAccount(for: type(of: self))
        printWarning()
    }
    
    func testGetsJobsCorrectly(){
        
        guard let account = account
            else { XCTFail("The account could not be parsed from Jenkins.plist"); return }
        
        let request = UserRequest.userRequestForJobList(account: account)
        
        let testExpectation = expectation(description: "Loading jobs from \(account.baseUrl) should work")
        
        
        manager.getJobs(userRequest: request){
            jobList, error in
            
            XCTAssertNil(error)
            
            guard let jobList = jobList
                else { XCTFail("Job list should not be nil!"); return }
            
            self.testJobListHasAllNecessaryValues(jobList: jobList)
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0){
            error in
            
            print("Test Timed out")
            
            if let e = error{
                print("Timed out with error: " + e.localizedDescription)
            }
        }
    }
    
    private func testJobListHasAllNecessaryValues(jobList: JobList){
        XCTAssertNotNil(jobList.allJobsView)
        
        for view in jobList.views{
            testViewHasAllNecessaryValues(view: view)
        }
    }
    
    private func testViewHasAllNecessaryValues(view: View){
        for jobResult in view.jobResults{
            testJobHasAllNecessaryValues(job: jobResult.data, isFullVersion: false)
        }
    }
    
    private func testJobHasAllNecessaryValues(job: Job, isFullVersion: Bool){
        XCTAssertNotNil(job.color)
        XCTAssert(job.isFullVersion == isFullVersion)
    }
    
    private func printWarning(){
        let warningString = "*** This test depends on a few factors. You need a network connection and the Jenkins.plist file to contain meaningful data. A failing test therefore does not mean the code is broken ***".colorized(with: ANSIColor.yellow)
        print(warningString)
    }
}






