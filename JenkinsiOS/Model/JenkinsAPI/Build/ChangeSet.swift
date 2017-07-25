//
//  ChangeSet.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ChangeSet{
    /// The kind of changeset
    var kind: String?
    /// The changes that are part of the change set
    var items: [Item] = []
    
    /// Initialise a ChangeSet object
    ///
    /// - parameter json: The json from which to initialse the object from
    ///
    /// - returns: An initialised ChangeSet object
    init(json: [String: AnyObject]){
        kind = json["kind"] as? String
        
        var commitIds: [String] = []
        
        (json["items"] as? [[String: AnyObject]])?.forEach({ (jsonItem) in
            if let item = Item(json: jsonItem){
                if let commitId = item.commitId, !commitIds.contains(commitId){
                    items.append(item)
                    commitIds.append(commitId)
                }
            }
        })
    }
}
