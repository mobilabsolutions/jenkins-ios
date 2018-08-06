//
//  JobTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 20.07.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var healthView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowView: UIImageView!
    
    func setup(with jobResult: JobListResult) {
        self.nameLabel.text = jobResult.name
        
        if let color = jobResult.color {
            self.statusView?.image = UIImage(named: color.rawValue + "Circle")
        }
        
        if let icon = jobResult.data.healthReport.first?.iconClassName {
            self.healthView.image = UIImage(named: icon)
        }
        
        containerView.layer.cornerRadius = 5
    }
}
