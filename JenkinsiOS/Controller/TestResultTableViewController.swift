//
//  TestResultTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class TestResultTableViewController: UITableViewController {

    var testCase: Case?{
        didSet{
            guard let testCase = testCase
                else { return }
            
            testCaseData = [
                ("Name", testCase.name ?? "No name", Constants.Identifiers.testResultCell),
                ("Class Name", testCase.className.textify(), Constants.Identifiers.testResultCell),
                ("Duration", testCase.duration != nil ? "\(testCase.duration!)ms" : "Unknown", Constants.Identifiers.testResultCell),
                ("Age", testCase.age.textify(), Constants.Identifiers.testResultCell),
                ("Status", testCase.status.textify(), Constants.Identifiers.testResultCell),
                ("Skipped", testCase.skipped.textify(), Constants.Identifiers.testResultCell),
                ("Error details", testCase.errorDetails ?? "No error details", Constants.Identifiers.testResultErrorDetailsCell)
            ]
            
            tableView.reloadData()
        }
    }
    private var testCaseData: [(String, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = testCase?.name
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testCaseData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: testCaseData[indexPath.row].2, for: indexPath)

        if testCaseData[indexPath.row].2 == Constants.Identifiers.testResultCell{
            cell.textLabel?.text = testCaseData[indexPath.row].0
            cell.detailTextLabel?.text = testCaseData[indexPath.row].1
        }
        else if testCaseData[indexPath.row].2 == Constants.Identifiers.testResultErrorDetailsCell, let errorCell = cell as? LongBuildInfoTableViewCell{
            errorCell.infoLabel.text = testCaseData[indexPath.row].1
            errorCell.titleLabel.text = testCaseData[indexPath.row].0
            errorCell.infoLabel.lineBreakMode = .byWordWrapping
        }
        return cell
    }
}
