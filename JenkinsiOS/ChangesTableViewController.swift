//
//  ChangesTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ChangesTableViewController: BaseTableViewController {

    var changeSetItems: [Item]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        title = "Changes"
        emptyTableView(for: .noData, customString: "There don't seem to be any changes here")
    }
    
    // MARK: - Table view data source

    override func numberOfSections() -> Int {
        return changeSetItems?.count ?? 0
    }
    
    override func tableViewIsEmpty() -> Bool {
        return (changeSetItems?.count ?? 0) == 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.changeCell, for: indexPath)
        
        if let change = changeSetItems?[indexPath.section], let changeCell = cell as? LongBuildInfoTableViewCell{
            switch indexPath.row{
                case 0:
                    changeCell.titleLabel.text = "Commit Author"
                    changeCell.infoLabel.text = change.author?.fullName ?? "No author"
                case 1:
                    changeCell.titleLabel.text = "Date"
                    changeCell.infoLabel.text = change.date ?? "No date"
                case 2:
                    changeCell.titleLabel.text = "Message"
                    changeCell.infoLabel.text = change.message ?? "No message"
                case 3:
                    changeCell.titleLabel.text = "Comment"
                    changeCell.infoLabel.text = change.comment ?? "No comment"
                default:
                    break
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return changeSetItems?[section].commitId
    }

}
