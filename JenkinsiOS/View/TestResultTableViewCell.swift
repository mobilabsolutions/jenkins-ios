//
//  TestResultTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class TestResultTableViewCell: UITableViewCell {
    @IBOutlet var testNameLabel: UILabel!
    @IBOutlet var testDurationLabel: UILabel!
    @IBOutlet var testResultImageView: UIImageView!
    @IBOutlet var container: UIView!

    var test: Case? {
        didSet {
            updateData()
        }
    }

    private func updateData() {
        testNameLabel.text = test?.name ?? "No name"

        if let duration = test?.duration {
            testDurationLabel.text = String(duration) + " ms"
        } else {
            testDurationLabel.text = "Unknown"
        }

        if let status = test?.status?.rawValue.lowercased() {
            testResultImageView.image = UIImage(named: "\(status)TestCase")
        } else {
            testResultImageView.image = UIImage(named: "failedTestCase")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        testNameLabel.textColor = Constants.UI.greyBlue
        testDurationLabel.textColor = Constants.UI.silver
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 5
        container.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        container.layer.borderWidth = 1
    }
}
