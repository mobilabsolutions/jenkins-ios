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
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var buildNameLabel: UILabel!
    @IBOutlet weak var buildEndLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
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
        self.container.layer.cornerRadius = 5
        self.container.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        self.container.layer.borderWidth = 1
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
            statusImageView.image = UIImage(named: "\(result)Circle")
        }
        else {
            statusImageView.image = UIImage(named: "inProgressCircle")
        }
    }
    
    private func updateEmptyBuildInformation() {
        buildNameLabel.text = "..."
        buildEndLabel.text = "..."
        statusImageView.image = nil
    }
}
