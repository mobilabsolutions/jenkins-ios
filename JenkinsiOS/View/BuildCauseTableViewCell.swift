//
//  BuildCauseTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 13.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildCauseTableViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var causeTitleLabel: UILabel!
    @IBOutlet weak var causeLabel: UILabel!
    @IBOutlet weak var testResultsButton: UIButton!
    @IBOutlet weak var logsButton: UIButton!
    @IBOutlet weak var artifactsButton: UIButton!
    
    weak var delegate: BuildsInformationOpeningDelegate?
    
    var build: Build? {
        didSet {
            updateInfo(for: build)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.causeTitleLabel.text = "Cause"
        self.causeLabel.text = "..."
        self.causeTitleLabel.textColor = Constants.UI.greyBlue
        self.causeLabel.textColor = Constants.UI.greyBlue
        
        testResultsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        logsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        artifactsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        testResultsButton.addTarget(self, action: #selector(showTestResults), for: .touchUpInside)
        logsButton.addTarget(self, action: #selector(showLogs), for: .touchUpInside)
        artifactsButton.addTarget(self, action: #selector(showArtifacts), for: .touchUpInside)
        
        self.container.layer.cornerRadius = 5
        self.container.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        self.container.layer.borderWidth = 1
    }
    
    private func updateInfo(for build: Build?) {
        var causes: [Cause] = []
        
        if let multipleCauses = build?.actions?.causes{
            for cause in multipleCauses{
                if !causes.contains{ $0.shortDescription == cause.shortDescription }{
                    causes.append(cause)
                }
            }
        }
        
        let causeText = causes.reduce("", { (str, cause) -> String in
            return str + cause.shortDescription + "\n"
        })
        
        causeLabel.text = causeText
        artifactsButton.isEnabled = build != nil && !build!.artifacts.isEmpty
        testResultsButton.isEnabled = build != nil
        logsButton.isEnabled = build != nil
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
}
