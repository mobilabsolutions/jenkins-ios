//
//  Searcher.swift
//  JenkinsiOS
//
//  Created by Robert on 14.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import Foundation

class Searcher: NSObject{
    
    /// The data that can be searched through
    var searchableData: [Searchable] = []
    /// The Searcher's delegate
    var delegate: SearcherDelegate
    
    /// Initialize a new searcher object with a given delegate and given searchable data
    ///
    /// - parameter searchableData: The searchable data that should be searched through
    /// - parameter delegate:       The searcher delegate
    ///
    /// - returns: An initialized Searcher object
    init(searchableData: [Searchable], delegate: SearcherDelegate) {
        self.searchableData = searchableData
        self.delegate = delegate
    }
    
    /// Search through and filter the searchable data for the given search string
    ///
    /// - parameter searchString: The string that the data should be searched and filtered for
    ///
    /// - returns: The searched through and filtered array of searchables
    func searchAndFilter(searchString: String) -> [Searchable]{
        
        let searchString = searchString.lowercased()
        
        return searchableData.filter({ (searchable) -> Bool in
            return searchable.lowerCasedSearchString.contains(searchString)
        }).sorted(by: { (first, second) -> Bool in
            first.lowerCasedSearchString.range(of: searchString)!.lowerBound < second.lowerCasedSearchString.range(of: searchString)!.lowerBound
        })
    }
}

extension Searcher: UISearchResultsUpdating{
    /// Update the relevant searchable data for the given search controller
    ///
    /// - parameter searchController: The search controller for which to update the searchable data
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text
            else { return }
        delegate.updatedData(data: searchAndFilter(searchString: text))
    }
    
}

protocol SearcherDelegate: class{
    /// Act on given updated data
    ///
    /// - parameter data: The updated (i.e. searched and filtered) search data
    func updatedData(data: [Searchable])
}
