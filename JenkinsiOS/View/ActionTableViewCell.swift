//
//  ActionTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 10.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class ActionTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    
    func setup(for action: JenkinsAction) {
        self.actionImageView.image = UIImage(named: action.imageName)
        self.actionLabel.text = action.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 5
        self.actionImageView.image = nil
        self.actionLabel.text = ""
        self.contentView.backgroundColor = Constants.UI.backgroundColor
        self.backgroundColor = .clear
        self.containerView.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        self.containerView.layer.borderWidth = 1
    }
}

private extension JenkinsAction {
    var imageName: String {
        switch self {
        case .cancelQuietDown:
            return "quiet-down-red"
        case .exit:
            return "exit"
        case .quietDown:
            return "quiet-down"
        case .restart:
            return "restart-red"
        case .safeExit:
            return "safe-exit"
        case .safeRestart:
            return "restart"
        }
    }
    
    var title: String {
        switch self {
        case .cancelQuietDown:
            return "Cancel Quiet Down"
        case .exit:
            return "Exit"
        case .quietDown:
            return "Quiet Down"
        case .restart:
            return "Restart"
        case .safeExit:
            return "Safe Exit"
        case .safeRestart:
            return "Safe Exit"
        }
    }
}
