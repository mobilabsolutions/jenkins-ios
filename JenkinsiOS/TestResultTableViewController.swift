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
                ("Name", testCase.name ?? "No name"),
                ("Class Name", testCase.className.textify()),
                ("Duration", testCase.duration != nil ? "\(testCase.duration!)ms" : "Unknown"),
                ("Age", testCase.age.textify()),
                ("Status", testCase.status.textify()),
                ("Skipped", testCase.skipped.textify()),
                ("Error details", testCase.errorDetails ?? "No error details")
            ]
            
            tableView.reloadData()
        }
    }
    private var testCaseData: [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = testCase?.name
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testCaseData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.testResultCell, for: indexPath)

        cell.textLabel?.text = testCaseData[indexPath.row].0
        cell.detailTextLabel?.text = testCaseData[indexPath.row].1
        
        return cell
    }
}
