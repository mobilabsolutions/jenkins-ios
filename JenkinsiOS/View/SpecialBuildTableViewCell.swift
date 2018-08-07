//
//  SpecialBuildTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 06.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol SpecialBuildsTableViewCellDelegate: class {
    func showLogs(build: Build)
    func showArtifacts(build: Build)
    func showTestResults(build: Build)
}

class SpecialBuildTableViewCell: UITableViewCell {

    var build: Build? {
        didSet {
            updateBuildInformation()
        }
    }
    
    @IBOutlet weak var buildStatusImageView: UIImageView!
    @IBOutlet weak var buildNameLabel: UILabel!
    @IBOutlet weak var buildEndLabel: UILabel!
    @IBOutlet weak var artifactsButton: UIButton!
    @IBOutlet weak var testResultsButton: UIButton!
    @IBOutlet weak var logsButton: UIButton!
    @IBOutlet weak var container: UIView!
    
    weak var delegate: SpecialBuildsTableViewCellDelegate?
    
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
        
        testResultsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        logsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        artifactsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        testResultsButton.addTarget(self, action: #selector(showTestResults), for: .touchUpInside)
        logsButton.addTarget(self, action: #selector(showLogs), for: .touchUpInside)
        artifactsButton.addTarget(self, action: #selector(showArtifacts), for: .touchUpInside)
        
        self.container.layer.cornerRadius = 5
    }
    
    private func updateBuildInformation() {
        
        guard let build = self.build
            else { updateEmptyBuildInformation(); return }
        
        buildNameLabel.text = build.fullDisplayName ?? build.displayName ?? "#" + String(build.number)
        if let timeStamp = build.timeStamp {
            buildEndLabel.text = dateFormatter.string(from: timeStamp, to: Date())
        }
        else {
            buildEndLabel.text = ""
        }
        
        if let result = build.result?.lowercased(){
            buildStatusImageView.image = UIImage(named: "\(result)Circle")
        }
        
        artifactsButton.isEnabled = !build.artifacts.isEmpty
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
}
