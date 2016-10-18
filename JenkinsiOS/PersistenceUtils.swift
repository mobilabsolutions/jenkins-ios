//
//  PersistenceUtils.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class PersistenceUtils{
    
    /// Get the url for the document directory with a path component added
    ///
    /// - returns: The URL describing the document directory with the added path component
    static func getDocumentDirectory() -> URL?{
        return (try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
    }
    
    /// Get the url of the app group's shared directory
    ///
    /// - returns: The URL describing the directory of the shared app group
    static func getSharedDirectory() -> URL?{
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.mobilabsolutions.jenkins.client.shared")
    }
}
