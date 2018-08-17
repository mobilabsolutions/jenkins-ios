//
//  UserTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 17.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var user: User? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fullNameLabel.textColor = Constants.UI.greyBlue
        selectionStyle = .none
        container.layer.cornerRadius = 5
        container.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        container.layer.borderWidth = 1
    }
    
    private func updateViews() {
        initialsLabel.text = user?.fullName.split(separator: " ").reduce(into: "", { (result, substring) in
            guard let first = substring.first
                else { return }
            result?.append(first)
        }) ?? "UN"
        
        fullNameLabel.text = user?.fullName ?? "Unknown"
    }
    
}
