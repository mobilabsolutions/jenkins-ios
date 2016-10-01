//
//  ChildReport.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ChildReport{
    var child: Child?
    var result: Result?
    
    init?(json: [String: AnyObject]){
        if let childJson = json[Constants.JSON.child] as? [String: AnyObject]{
            child = Child(json: childJson)
        }
        if let resultJson = json[Constants.JSON.result] as? [String: AnyObject]{
            result = Result(json: resultJson)
        }
    }
}
