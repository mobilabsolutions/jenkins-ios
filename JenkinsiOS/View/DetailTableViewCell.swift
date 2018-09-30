//
//  DetailTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 10.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    @IBOutlet var container: CorneredView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.setBackgroundColor(for: selected)
            }
        } else {
            setBackgroundColor(for: selected)
        }
    }

    private func setBackgroundColor(for selected: Bool) {
        container.backgroundColor = selected ? UIColor.lightGray.withAlphaComponent(0.3) : .white
    }
}
