//
//  Child.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Child{
    var number: Int?
    var url: URL?
    
    init?(json: [String: AnyObject]){
        number = json[Constants.JSON.number] as? Int
        if let urlString = json[Constants.JSON.url] as? String{
            url = URL(string: urlString)
        }
    }
}
