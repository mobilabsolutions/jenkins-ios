//
//  Searchable.swift
//  JenkinsiOS
//
//  Created by Robert on 14.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Searchable{
    private(set) var data: AnyObject
    private(set) var searchString: String
    private(set) var action: () -> ()
    
    private(set) var lowerCasedSearchString: String
    
    init(searchString: String, data: AnyObject, action: @escaping () -> ()) {
        self.searchString = searchString
        self.data = data
        self.action = action
        self.lowerCasedSearchString = searchString.lowercased()
    }
    
}
