//
//  SpecialBuildTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 06.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol BuildsInformationOpeningDelegate: class {
    func showLogs(build: Build)
    func showArtifacts(build: Build)
    func showTestResults(build: Build)
    func showChanges(build: Build)
}

class SpecialBuildTableViewCell: UITableViewCell {
    var build: Build? {
        didSet {
            updateBuildInformation()
        }
    }

    @IBOutlet var buildStatusImageView: UIImageView!
    @IBOutlet var buildNameLabel: UILabel!
    @IBOutlet var buildEndLabel: UILabel!
    @IBOutlet var artifactsButton: UIButton!
    @IBOutlet var testResultsButton: UIButton!
    @IBOutlet var logsButton: UIButton!
    @IBOutlet var changesButton: UIButton!
    @IBOutlet var container: UIView!

    weak var delegate: BuildsInformationOpeningDelegate?

    private let dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .full
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        buildNameLabel.text = "..."
        buildEndLabel.text = "..."

        testResultsButton.centerButtonImageAndTitle()
        logsButton.centerButtonImageAndTitle()
        artifactsButton.centerButtonImageAndTitle()
        changesButton.centerButtonImageAndTitle()

        testResultsButton.addTarget(self, action: #selector(showTestResults), for: .touchUpInside)
        logsButton.addTarget(self, action: #selector(showLogs), for: .touchUpInside)
        artifactsButton.addTarget(self, action: #selector(showArtifacts), for: .touchUpInside)
        changesButton.addTarget(self, action: #selector(showChanges), for: .touchUpInside)

        container.layer.cornerRadius = 5
        container.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        container.layer.borderWidth = 1
    }

    private func updateBuildInformation() {
        guard let build = self.build
        else { updateEmptyBuildInformation(); return }

        buildNameLabel.text = build.fullDisplayName ?? build.displayName ?? "#" + String(build.number)
        if let timeStamp = build.timeStamp {
            buildEndLabel.text = dateFormatter.string(from: timeStamp, to: Date())?.appending(" ago")
        } else {
            buildEndLabel.text = ""
        }

        if let result = build.result?.lowercased() {
            buildStatusImageView.image = UIImage(named: "\(result)Circle")
        } else {
            buildStatusImageView.image = UIImage(named: "inProgressCircle")
        }

        artifactsButton.isEnabled = !build.artifacts.isEmpty
        changesButton.isEnabled = !build.allChangeItems.isEmpty
        testResultsButton.isEnabled = true
        logsButton.isEnabled = true
    }

    private func updateEmptyBuildInformation() {
        buildNameLabel.text = "..."
        buildEndLabel.text = "..."
        buildStatusImageView.image = nil
        artifactsButton.isEnabled = false
        testResultsButton.isEnabled = false
        logsButton.isEnabled = false
    }

    @objc private func showArtifacts() {
        guard let build = self.build
        else { return }
        delegate?.showArtifacts(build: build)
    }

    @objc private func showTestResults() {
        guard let build = self.build
        else { return }
        delegate?.showTestResults(build: build)
    }

    @objc private func showLogs() {
        guard let build = self.build
        else { return }
        delegate?.showLogs(build: build)
    }

    @objc private func showChanges() {
        guard let build = self.build
        else { return }
        delegate?.showChanges(build: build)
    }
}
