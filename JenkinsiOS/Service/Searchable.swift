//
//  Searchable.swift
//  JenkinsiOS
//
//  Created by Robert on 14.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Searchable {
    /// The object associated with the given searchable
    private(set) var data: AnyObject
    /// The string that identifies the given object to the Searcher
    private(set) var searchString: String
    /// The action that should be taken once the searchable is selected
    private(set) var action: () -> Void

    /// The lowercased search string for better string comparability, as case typically does not matter for search
    private(set) var lowerCasedSearchString: String

    /// Initialiser for Searchable
    ///
    /// - parameter searchString: The string that identifies the given object to the Searcher
    /// - parameter data:         The object associated with the given searchable
    /// - parameter action:       The action that should be taken once the searchable is selected
    ///
    /// - returns: An initialised Searchable
    init(searchString: String, data: AnyObject, action: @escaping () -> Void) {
        self.searchString = searchString
        self.data = data
        self.action = action
        lowerCasedSearchString = searchString.lowercased()
    }
}
