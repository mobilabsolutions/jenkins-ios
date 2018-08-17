//
//  BasicTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 07.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class BasicTableViewCell: UITableViewCell {

    var title: String {
        get {
            return label?.text ?? ""
        }
        set {
            label?.text = newValue
        }
    }
    
    var nextImageType: NextImageType = .next {
        didSet {
            self.nextImageView?.image = nextImageType != .none ? UIImage(named: nextImageType.rawValue) : nil
        }
    }
    
    enum NextImageType: String {
        case next = "arrow-right"
        case checkmark = "ic-checked"
        case none = ""
    }
    
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var nextImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = Constants.UI.backgroundColor
        label?.textColor = Constants.UI.greyBlue
    }
}
