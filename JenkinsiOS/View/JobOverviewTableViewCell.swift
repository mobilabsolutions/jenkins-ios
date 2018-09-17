//
//  JobOverviewTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 06.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobOverviewTableViewCell: UITableViewCell {
    
    var job: Job? {
        didSet {
            updateCellForJob()
        }
    }
    
    @IBOutlet weak var healthStatusImageView: UIImageView!
    @IBOutlet weak var testResultTitleLabel: UILabel!
    @IBOutlet weak var testResultContentLabel: UILabel!
    @IBOutlet weak var buildStabilityTitleLabel: UILabel!
    @IBOutlet weak var buildStabilityContentLabel: UILabel!
    @IBOutlet weak var lastDurationTitleLabel: UILabel!
    @IBOutlet weak var lastDurationContentLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        testResultContentLabel.text = "..."
        buildStabilityContentLabel.text = "..."
        lastDurationContentLabel.text = "..."
        
        testResultTitleLabel.textColor = Constants.UI.greyBlue
        buildStabilityTitleLabel.textColor = Constants.UI.greyBlue
        lastDurationTitleLabel.textColor = Constants.UI.greyBlue
        
        self.container.layer.cornerRadius = 5
        self.container.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        self.container.layer.borderWidth = 1
    }

    private func updateCellForJob() {
        guard let job = self.job
            else { setupCellForEmptyJob(); return }
        
        testResultContentLabel.text = job.healthReport.first(where: { $0.description.localizedCaseInsensitiveContains("test") })?.description ?? "Unknown"
        buildStabilityContentLabel.text = job.healthReport.first(where: { $0.description.localizedCaseInsensitiveContains("build") })?.description ?? "Unknown"
        lastDurationContentLabel.text = job.lastBuild?.duration?.toString() ?? "Unknown"
        
        if let healthReportImageName = job.healthReport.first?.iconClassName {
            healthStatusImageView.image = UIImage(named: healthReportImageName)
        }
        else {
            healthStatusImageView.image = nil
        }
    }
    
    private func setupCellForEmptyJob() {
        testResultContentLabel.text = "..."
        buildStabilityContentLabel.text = "..."
        lastDurationContentLabel.text = "..."
        healthStatusImageView.image = nil
    }
}
