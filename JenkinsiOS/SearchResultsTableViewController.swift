//
//  SearchResultsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 14.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    var searcher: Searcher?
    var searchData: [Searchable] = []
    var delegate: SearchResultsControllerDelegate?
    var cellStyle: UITableViewCellStyle?
    
    fileprivate var displayingData: [Searchable] = []
    
    
    init(searchData: [Searchable]){
        super.init(style: .plain)
        self.searchData = searchData
        searcher = Searcher(searchableData: searchData, delegate: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayingData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") ?? UITableViewCell(style: cellStyle ?? .default, reuseIdentifier: "searchCell")
        
        if let delegate = delegate{
            delegate.setup(cell: cell, for: displayingData[indexPath.row])
        }
        else{
            cell.textLabel?.text = displayingData[indexPath.row].searchString
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayingData[indexPath.row].action()
    }
    
}

extension SearchResultsTableViewController: SearcherDelegate{
    func updatedData(data: [Searchable]) {
        displayingData = data
        tableView.reloadData()
    }
}

protocol SearchResultsControllerDelegate: class {
    func setup(cell: UITableViewCell, for searchable: Searchable)
}
