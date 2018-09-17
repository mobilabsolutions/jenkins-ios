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
        didSet {
            guard let testCase = testCase
            else { return }

            testCaseData = [
                ("Class Name", testCase.className.textify(), Constants.Identifiers.testResultCell),
                ("Age", testCase.age.textify(), Constants.Identifiers.testResultCell),
                ("Status", testCase.status.textify(), Constants.Identifiers.testResultCell),
                ("Skipped", testCase.skipped.textify(), Constants.Identifiers.testResultCell),
                ("Error details", testCase.errorDetails ?? "No error details", Constants.Identifiers.testResultErrorDetailsCell),
            ]

            tableView.reloadData()
            updateHeader()
        }
    }

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!

    private var testCaseData: [(String, String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Case"

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension

        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.testResultCell)

        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none

        nameLabel.textColor = Constants.UI.greyBlue
        durationLabel.textColor = Constants.UI.darkGrey
    }

    private func updateHeader() {
        nameLabel.text = testCase?.name ?? "No name"
        durationLabel.text = testCase?.duration != nil ? "Duration: \(testCase!.duration.textify()) ms" : "Duration: Unknown"

        guard let header = self.tableView.tableHeaderView
        else { return }

        let offsetSum: CGFloat = 30

        nameLabel.sizeToFit()
        durationLabel.sizeToFit()
        header.frame = CGRect(origin: header.frame.origin, size: CGSize(width: header.frame.width, height: nameLabel.frame.height + durationLabel.frame.height + offsetSum))
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
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
        } else if testCaseData[indexPath.row].2 == Constants.Identifiers.testResultErrorDetailsCell, let errorCell = cell as? LongBuildInfoTableViewCell {
            errorCell.infoLabel.text = testCaseData[indexPath.row].1
            errorCell.titleLabel.text = testCaseData[indexPath.row].0
            errorCell.infoLabel.lineBreakMode = .byWordWrapping
            errorCell.container.borders = [.left, .right, .bottom]
            errorCell.container.cornersToRound = [.bottomLeft, .bottomRight]
        }
        return cell
    }
}
