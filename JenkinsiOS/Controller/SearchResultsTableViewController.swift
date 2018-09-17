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

    fileprivate var displayingData: [Searchable] = []
    private var cellNib: UINib

    init(searchData: [Searchable], cellNib: UINib) {
        self.searchData = searchData
        self.cellNib = cellNib
        super.init(style: .plain)
        searcher = Searcher(searchableData: searchData, delegate: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cellNib, forCellReuseIdentifier: "searchCell")
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none

        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = []
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return displayingData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") ?? UITableViewCell(style: .default, reuseIdentifier: "searchCell")

        if let delegate = delegate {
            delegate.setup(cell: cell, for: displayingData[indexPath.row])
        } else {
            cell.textLabel?.text = displayingData[indexPath.row].searchString
        }
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayingData[indexPath.row].action()
    }
}

extension SearchResultsTableViewController: SearcherDelegate {
    func updatedData(data: [Searchable]) {
        displayingData = data
        tableView.reloadData()
    }
}

protocol SearchResultsControllerDelegate: class {
    func setup(cell: UITableViewCell, for searchable: Searchable)
}
