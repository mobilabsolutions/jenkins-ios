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
    
    /// Whether or not to include all searchables if there is no input given
    var includeAllOnEmptySearchString: Bool = false
    
    /// The condition that should also be met for a searchable to be included
    var additionalSearchCondition: ((Searchable, String?) -> Bool)? = nil
    
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
    func searchAndFilter(searchString: String, scope: String? = nil) -> [Searchable]{
        let searchString = searchString.lowercased()
        
        if includeAllOnEmptySearchString{
            return searchableData.filter({ (searchable) -> Bool in
                return additionalSearchCondition?(searchable, scope) ?? true
            })
        }
        
        return searchableData.filter({ (searchable) -> Bool in
            return searchable.lowerCasedSearchString.contains(searchString) && (additionalSearchCondition?(searchable, scope) ?? true)
        }).sorted(by: { (first, second) -> Bool in
            first.lowerCasedSearchString.range(of: searchString)!.lowerBound < second.lowerCasedSearchString.range(of: searchString)!.lowerBound
        })
    }
    
    fileprivate func updateSearchResults(for searchBar: UISearchBar){
        guard let text = searchBar.text
            else { return }
        
        var scope: String? = nil
        
        if let scopes = searchBar.scopeButtonTitles{
            scope = scopes[searchBar.selectedScopeButtonIndex]
        }

        delegate.updatedData(data: searchAndFilter(searchString: text, scope: scope))
    }
    
    fileprivate func toggleResultsControllerTableView(controller: UISearchController){
        if includeAllOnEmptySearchString, controller.searchBar.text?.isEmpty ?? false,
            let resultsController = controller.searchResultsController as? SearchResultsTableViewController{
            resultsController.tableView.isHidden = false
        }
    }
}

extension Searcher: UISearchResultsUpdating{
    /// Update the relevant searchable data for the given search controller
    ///
    /// - parameter searchController: The search controller for which to update the searchable data
    func updateSearchResults(for searchController: UISearchController) {
        updateSearchResults(for: searchController.searchBar)
        toggleResultsControllerTableView(controller: searchController)
    }
}

extension Searcher: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        updateSearchResults(for: searchBar)
    }
}

protocol SearcherDelegate: class{
    /// Act on given updated data
    ///
    /// - parameter data: The updated (i.e. searched and filtered) search data
    func updatedData(data: [Searchable])
}
