//
//  QueueItem.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class QueueItem {
    /// The actions associated with the queue item
    var actions: Actions?
    
    /// Whether or not the item is blocked
    var blocked: Bool
    /// Whether or not the item is buildable
    var buildable: Bool
    /// The queue item's id
    var id: Int
    /// How long the queue item has been in the queue
    var inQueueSince: Double
    /// Parameters that have been added to the queue item
    var params: String
    /// Whether or not the queue item is stuck
    var stuck: Bool
    /// A url associated with the queue item
    var url: URL?
    /// The reason for the item being in the queue
    var why: String
    /// The task associated with the queue item
    var task: Job?
    /// When the queue item is buildable
    var buildableStartMilliseconds: Double
    
    /// Optionally initialise a Queue Item
    ///
    /// - parameter json: The json to initialise the queue item from
    ///
    /// - returns: A queue item or nil, if the initialization failed
    init?(json: [String: AnyObject]){
        guard let blocked = json[Constants.JSON.blocked] as? Bool,
            let buildable = json[Constants.JSON.buildable] as? Bool,
            let id = json[Constants.JSON.id] as? Int,
            let inQueueSince = json[Constants.JSON.inQueueSince] as? Double,
            let params = json[Constants.JSON.params] as? String,
            let urlString = json[Constants.JSON.url] as? String,
            let stuck = json[Constants.JSON.stuck] as? Bool,
            let why = json[Constants.JSON.why] as? String,
            let buildableStartMilliseconds = json[Constants.JSON.buildableStartMilliseconds] as? Double
            else { return nil }
        
        self.blocked = blocked
        self.buildable = buildable
        self.id = id
        self.inQueueSince = inQueueSince
        self.params = params
        self.stuck = stuck
        self.url = URL(string: urlString)
        self.why = why
        self.buildableStartMilliseconds = buildableStartMilliseconds
        
        if let taskJson = json[Constants.JSON.task] as? [String: AnyObject]{
            task = Job(json: taskJson, minimalVersion: true)
        }
        
        if let actionsJson = json[Constants.JSON.actions] as? [[String: AnyObject]]{
            actions = Actions(json: actionsJson)
        }
    }
}
