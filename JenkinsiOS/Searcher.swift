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
    
    var searchableData: [Searchable] = []
    var delegate: SearcherDelegate
    
    init(searchableData: [Searchable], delegate: SearcherDelegate) {
        self.searchableData = searchableData
        self.delegate = delegate
    }
    
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
 
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text
            else { return }
        delegate.updatedData(data: searchAndFilter(searchString: text))
    }
    
}

protocol SearcherDelegate: class{
    func updatedData(data: [Searchable])
}
