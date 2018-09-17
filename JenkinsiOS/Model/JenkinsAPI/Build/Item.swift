//
//  Item.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Item {
    /// The paths that are affected by the Change
    var affectedPaths: [String]
    /// The commit id of the change
    var commitId: String?
    /// The timestamp at which the change was committed
    var timestamp: TimeInterval
    /// The change's author
    var author: Author?
    /// A comment that was added to the change
    var comment: String?
    /// The change's date
    var date: String?
    /// A message that was added to the change
    var message: String?

    /// Optionally initialise an Item
    ///
    /// - parameter json: The json from which to initialize the item
    ///
    /// - returns: An initialized Item or nil
    init?(json: [String: Any]) {
        guard let affectedPaths = json["affectedPaths"] as? [String], let timestamp = json["timestamp"] as? TimeInterval
        else { return nil }

        self.affectedPaths = affectedPaths
        self.timestamp = timestamp

        commitId = json["commitId"] as? String
        comment = json["comment"] as? String
        date = json["date"] as? String
        message = json["msg"] as? String

        if let jsonAuthor = json["author"] as? [String: AnyObject] {
            author = Author(json: jsonAuthor)
        }
    }
}
