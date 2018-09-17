//
//  BuildTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 06.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildTableViewCell: UITableViewCell {
    var build: Build? {
        didSet {
            updateBuildInformation()
        }
    }

    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var buildNameLabel: UILabel!
    @IBOutlet var buildEndLabel: UILabel!
    @IBOutlet var container: UIView!

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
            statusImageView.image = UIImage(named: "\(result)Circle")
        } else {
            statusImageView.image = UIImage(named: "inProgressCircle")
        }
    }

    private func updateEmptyBuildInformation() {
        buildNameLabel.text = "..."
        buildEndLabel.text = "..."
        statusImageView.image = nil
    }
}
