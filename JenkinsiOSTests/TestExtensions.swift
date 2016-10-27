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


