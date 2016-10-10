//
//  BuildQueue.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class BuildQueue{
    
    var items: [QueueItem] = []
    
    init?(json: [String: AnyObject]){
        guard let itemsJson = json[Constants.JSON.items] as? [[String: AnyObject]]
            else { return nil }
        for itemJson in itemsJson{
            if let item = QueueItem(json: itemJson){
                items.append(item)
            }
        }
    }
}
