//
//  TestExtensions.swift
//  JenkinsiOS
//
//  Created by Robert on 18.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation
import XCTest

func AssertEmpty<T>(_ value: [T]){
    XCTAssertTrue(value.isEmpty)
}

func AssertNotEmpty<T>(_ value: [T]){
    XCTAssertFalse(value.isEmpty)
}

func assertArraysAreEqual(array1: [Any?], array2: [Any?]){
    guard array1.count == array2.count
        else { XCTFail("Arrays do not have the same length: first: \(array1.count) second: \(array2.count)"); return }
    
    for (index, element) in array1.enumerated(){
        
        guard (element != nil && array2[index] != nil)
            else { if(!(element == nil && array2[index] == nil)){ XCTFail("\(String(describing: element)) is not the same as \(String(describing: array2[index]))") }; continue }
        
        if((element as? NSObject) != (array2[index] as? NSObject)){
            XCTFail("\(String(describing: element)) is not the same as \(String(describing: array2[index]))")
        }
    }
}
