//
//  TestResultTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class TestResultTableViewController: UITableViewController {

    var testCase: Case? {
        didSet{
            guard let testCase = testCase
                else { return }
            
            testCaseData = [
                ("Class Name", testCase.className.textify(), Constants.Identifiers.testResultCell),
                ("Age", testCase.age.textify(), Constants.Identifiers.testResultCell),
                ("Status", testCase.status.textify(), Constants.Identifiers.testResultCell),
                ("Skipped", testCase.skipped.textify(), Constants.Identifiers.testResultCell),
                ("Error details", testCase.errorDetails ?? "No error details", Constants.Identifiers.testResultErrorDetailsCell)
            ]
            
            tableView.reloadData()
            updateHeader()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    private var testCaseData: [(String, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Case"
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(UINib(nibName: "DetailTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.testResultCell)
        
        self.tableView.backgroundColor = Constants.UI.backgroundColor
        self.tableView.separatorStyle = .none
        
        self.nameLabel.textColor = Constants.UI.greyBlue
        self.durationLabel.textColor = Constants.UI.darkGrey
    }
    
    private func updateHeader() {
        self.nameLabel.text = testCase?.name ?? "No name"
        self.durationLabel.text = testCase?.duration != nil ? "Duration: \(testCase!.duration.textify()) ms" : "Duration: Unknown"
        
        guard let header = self.tableView.tableHeaderView
            else { return }
        
        let offsetSum: CGFloat = 30
        
        self.nameLabel.sizeToFit()
        self.durationLabel.sizeToFit()
        header.frame = CGRect(origin: header.frame.origin, size: CGSize(width: header.frame.width, height: self.nameLabel.frame.height + self.durationLabel.frame.height + offsetSum))
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
        cell.selectionStyle = .none
        
        if testCaseData[indexPath.row].2 == Constants.Identifiers.testResultCell, let cell = cell as? DetailTableViewCell {
            cell.titleLabel.text = testCaseData[indexPath.row].0
            cell.detailLabel.text = testCaseData[indexPath.row].1
            cell.container.borders = [.left, .right, .bottom]
            cell.container.cornersToRound = []
            
            if indexPath.row == 0 {
                cell.container.borders.insert(.top)
                cell.container.cornersToRound = [.topLeft, .topRight]
            }
        }
        else if testCaseData[indexPath.row].2 == Constants.Identifiers.testResultErrorDetailsCell, let errorCell = cell as? LongBuildInfoTableViewCell{
            errorCell.infoLabel.text = testCaseData[indexPath.row].1
            errorCell.titleLabel.text = testCaseData[indexPath.row].0
            errorCell.infoLabel.lineBreakMode = .byWordWrapping
            errorCell.container.borders = [.left, .right, .bottom]
            errorCell.container.cornersToRound = [.bottomLeft, .bottomRight]
        }
        return cell
    }
}
