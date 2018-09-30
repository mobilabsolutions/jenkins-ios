//
//  BuildQueue.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class BuildQueue {
    /// The items that are in the build queue
    var items: [QueueItem] = []

    /// Optionally initialise a build queue object
    ///
    /// - parameter json: The json to initialise the build queue from
    ///
    /// - returns: An optionally initialised build queue or nil
    init?(json: [String: AnyObject]) {
        guard let itemsJson = json[Constants.JSON.items] as? [[String: AnyObject]]
        else { return nil }
        for itemJson in itemsJson {
            if let item = QueueItem(json: itemJson) {
                items.append(item)
            }
        }
    }
}
