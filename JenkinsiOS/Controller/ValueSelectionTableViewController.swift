//
//  ValueSelectionTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 01.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol ValueSelectionTableViewControllerDelegate {
    associatedtype ValueSelectionTableViewControllerType: CustomStringConvertible, Equatable
    func didSelect(value: ValueSelectionTableViewControllerType)
}

class ValueSelectionTableViewController<S: ValueSelectionTableViewControllerDelegate>: UITableViewController {

    private let reuseIdentifer = "valueCell"
    
    var values: [S.ValueSelectionTableViewControllerType] = [] {
        didSet {
            selectedValue = selectedValue ?? values.first
            tableView.reloadData()
        }
    }
    
    typealias ValueSelectionTableViewControllerType = S.ValueSelectionTableViewControllerType
    
    var selectedValue: S.ValueSelectionTableViewControllerType?
    
    var delegate: S?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifer)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath)
        cell.accessoryType = values[indexPath.row] == selectedValue ? .checkmark : .none
        cell.textLabel?.text = values[indexPath.row].description
        cell.textLabel?.textColor = Constants.UI.steel
        cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(value: values[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
}
