//
//  BuildCauseTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 13.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildCauseTableViewCell: UITableViewCell {
    @IBOutlet var container: UIView!
    @IBOutlet var causeTitleLabel: UILabel!
    @IBOutlet var causeLabel: UILabel!
    @IBOutlet var testResultsButton: UIButton!
    @IBOutlet var logsButton: UIButton!
    @IBOutlet var artifactsButton: UIButton!
    @IBOutlet var changesButton: UIButton!

    weak var delegate: BuildsInformationOpeningDelegate?

    var build: Build? {
        didSet {
            updateInfo(for: build)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        causeTitleLabel.text = "Cause"
        causeLabel.text = "..."
        causeTitleLabel.textColor = Constants.UI.greyBlue
        causeLabel.textColor = Constants.UI.greyBlue

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

    private func updateInfo(for build: Build?) {
        var causes: [Cause] = []

        if let multipleCauses = build?.actions?.causes {
            for cause in multipleCauses {
                if !causes.contains { $0.shortDescription == cause.shortDescription } {
                    causes.append(cause)
                }
            }
        }

        let causeText = causes.reduce("", { (str, cause) -> String in
            str + cause.shortDescription + "\n"
        })

        causeLabel.text = causeText
        artifactsButton.isEnabled = build != nil && !build!.artifacts.isEmpty
        testResultsButton.isEnabled = build != nil
        logsButton.isEnabled = build != nil
        changesButton.isEnabled = !(build?.allChangeItems.isEmpty ?? true)
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
