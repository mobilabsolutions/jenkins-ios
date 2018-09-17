//
//  LongBuildInfoTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class LongBuildInfoTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var container: CorneredView!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = Constants.UI.steel
        infoLabel.textColor = Constants.UI.skyBlue
    }
}
