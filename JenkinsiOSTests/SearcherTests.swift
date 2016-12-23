//
//  SearcherTests.swift
//  JenkinsiOS
//
//  Created by Robert on 10.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class SearcherTests: XCTestCase, SearcherDelegate {
    
    var actionOnUpdatedData: (([Searchable]) -> ())?
    var searcher: Searcher?
    
    private var givenData: [Searchable] = []
    
    override func setUp() {
        actionOnUpdatedData = nil
        givenData = [
            Searchable(searchString: "ThisIsATest", data: "ThisIsATestString" as AnyObject, action: {}),
            Searchable(searchString: "ILikeItVeryMuch", data: "ILikeItVeryMuch" as AnyObject, action: {}),
            Searchable(searchString: "TastyTest", data: "AmazinglyTesty" as AnyObject, action: {})
        ]
        searcher = Searcher(searchableData: givenData, delegate: self)
    }
    
    func testInitializesProperly(){
        guard let searcher = searcher
            else { XCTFail("Searcher is nil!"); return }
        
        XCTAssertTrue(searcher.delegate === self)
        XCTAssertEqual(searcher.searchableData.count, 3)
        assertArraysAreEqual(array1: searcher.searchableData.map{ $0.searchString }, array2: givenData.map{ $0.searchString })
    }
    
    func testSearchesAndFiltersProperly(){
        guard let searcher = searcher
            else { XCTFail("Searcher is nil!"); return }
        
        let data = searcher.searchAndFilter(searchString: "Test")
        assertIsTheSameAsWhenSearchingForTest(data: data)
    }
    
    func testUpdatesDelegateProperly(){
        guard let searcher = searcher
            else { XCTFail("Searcher is nil!"); return }
        
        let searchController = UISearchController()
        searchController.searchBar.text = "Test"
        
        actionOnUpdatedData = {
            data in
            self.assertIsTheSameAsWhenSearchingForTest(data: data)
        }
        
        searcher.updateSearchResults(for: searchController)
    }
    
    func updatedData(data: [Searchable]) {
        actionOnUpdatedData?(data)
    }
    
    private func assertIsTheSameAsWhenSearchingForTest(data: [Searchable]){
        assertArraysAreEqual(array1: data.map{ $0.searchString }, array2: [
            "TastyTest", "ThisIsATest"
            ])
    }
}
