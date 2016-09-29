//
//  ChangeSet.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ChangeSet{
    var kind: String?
    var items: [Item] = []
    
    init(json: [String: AnyObject]){
        kind = json["kind"] as? String
        (json["items"] as? [[String: AnyObject]])?.forEach({ (jsonItem) in
            if let item = Item(json: jsonItem){
                items.append(item)
            }
        })
    }
}
