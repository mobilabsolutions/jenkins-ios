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
    /// - parameter path:      The path component that should be added to the directory
    /// - parameter directory: Whether or not the path is a directory
    ///
    /// - returns: The URL describing the document directory with the added path component
    static func getDocumentDirectory() -> URL?{
        return (try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
    }
}
