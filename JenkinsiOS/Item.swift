//
//  Item.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Item{
    var affectedPaths: [String]
    var commitId: String?
    var timestamp: TimeInterval
    var author: Author?
    var comment: String?
    var date: String?
    var message: String?
    
    init?(json: [String: Any]){
        guard let affectedPaths = json["affectedPaths"] as? [String], let timestamp = json["timestamp"] as? TimeInterval
            else { return nil }
        
        self.affectedPaths = affectedPaths
        self.timestamp = timestamp
        
        commitId = json["commitId"] as? String
        comment = json["comment"] as? String
        date = json["date"] as? String
        //FIXME: it is not actually clear, if that is the correct key
        message = json["msg"] as? String
        
        if let jsonAuthor = json["author"] as? [String: AnyObject]{
            author = Author(json: jsonAuthor)
        }
    }
}
