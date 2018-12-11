//
//  CreationTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 27.11.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class CreationTableViewCell: UITableViewCell {
    @IBOutlet var addButtonImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = Constants.UI.weirdGreen
    }
}
