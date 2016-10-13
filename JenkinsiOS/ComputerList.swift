//
//  ComputerList.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ComputerList{
    var busyExecutors: Int
    var computers: [Computer] = []
    var displayName: String
    var totalExecutors: Int
    
    init?(json: [String: Any]){
        guard let busyExecutors = json["busyExecutors"] as? Int, let displayName = json["displayName"] as? String, let totalExecutors = json["totalExecutors"] as? Int
            else { return nil }
        
        self.busyExecutors = busyExecutors
        self.displayName = displayName
        self.totalExecutors = totalExecutors
        
        (json["computer"] as? [[String: AnyObject]])?.forEach({ (computerJSON) in
            if let computer = Computer(json: computerJSON){
                self.computers.append(computer)
            }
        })
    
    }
}
