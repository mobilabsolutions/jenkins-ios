//
//  DataRetriever.swift
//  JenkinsiOS
//
//  Created by Robert on 14.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class DataRetriever {
    static let retriever = DataRetriever()
    private init() {}

    func getSharedApplicationUser() -> ApplicationUser? {
        guard let path = Constants.Paths.sharedUserPath?.path
        else { return nil }

        NSKeyedUnarchiver.setClass(ApplicationUser.self, forClassName: "JenkinsiOS.ApplicationUser")
        NSKeyedUnarchiver.setClass(Favorite.self, forClassName: "JenkinsiOS.Favorite")

        return NSKeyedUnarchiver.unarchiveObject(withFile: path) as? ApplicationUser
    }
}
