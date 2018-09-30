//
//  JobTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 20.07.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var statusView: UIImageView!
    @IBOutlet var healthView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var arrowView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        containerView.layer.borderWidth = 1
    }

    func setup(with jobResult: JobListResult) {
        nameLabel.text = jobResult.name

        if let color = jobResult.color {
            statusView?.image = UIImage(named: color.rawValue + "Circle")
        }

        if let icon = jobResult.data.healthReport.first?.iconClassName {
            healthView.image = UIImage(named: icon)
        } else if jobResult.color == .folder {
            healthView.image = UIImage(named: "icon-health-folder")
        } else {
            healthView.image = UIImage(named: "icon-health-unknown")
        }

        containerView.layer.cornerRadius = 5
    }
}
