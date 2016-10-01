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
    
    class QueueItem{
        var actions: Actions?
        
        var blocked: Bool
        var buildable: Bool
        var id: Int
        var inQueueSince: Double
        var params: String
        var stuck: Bool
        var url: URL?
        var why: String
        var task: Task?
        var buildableStartMilliseconds: Double
        
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
                task = Task(json: taskJson)
            }
            
            if let actionsJson = json[Constants.JSON.actions] as? [[String: AnyObject]]{
                actions = Actions(json: actionsJson)
            }
        }
        
        class Task{
            var name: String
            var url: URL?
            var color: JenkinsColor?
            
            init?(json: [String: AnyObject]){
                guard let name = json[Constants.JSON.name] as? String
                    else { return nil }
                self.name = name
                
                if let urlString = json[Constants.JSON.url] as? String{
                    url = URL(string: urlString)
                }
                
                if let colorString = json[Constants.JSON.color] as? String{
                    color = JenkinsColor(rawValue: colorString)
                }
                
            }
        }
    }
}
