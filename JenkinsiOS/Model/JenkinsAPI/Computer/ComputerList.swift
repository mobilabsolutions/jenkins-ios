//
//  ComputerList.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ComputerList {
    /// The total number of busy executors
    var busyExecutors: Int
    /// The list of computers available
    var computers: [Computer] = []
    /// The display name of the given computer list
    var displayName: String
    /// The total number of executors
    var totalExecutors: Int

    /// Optionally initialize a ComputerList object
    ///
    /// - parameter json: The json from which to initialize the computer list
    ///
    /// - returns: The initialized computer list or nil, if initialization failed
    init?(json: [String: Any]) {
        guard let busyExecutors = json["busyExecutors"] as? Int, let displayName = json["displayName"] as? String, let totalExecutors = json["totalExecutors"] as? Int
        else { return nil }

        self.busyExecutors = busyExecutors
        self.displayName = displayName
        self.totalExecutors = totalExecutors

        (json["computer"] as? [[String: AnyObject]])?.forEach({ computerJSON in
            if let computer = Computer(json: computerJSON) {
                self.computers.append(computer)
            }
        })
    }
}
