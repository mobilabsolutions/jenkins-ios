//
//  ActionCollectionViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 10.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class ActionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var actionImageView: UIImageView!
    @IBOutlet var actionLabel: UILabel!

    func setup(for action: JenkinsAction) {
        actionImageView.image = UIImage(named: action.imageName)
        actionLabel.text = action.title
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 5
        actionImageView.image = nil
        actionLabel.text = ""
        contentView.backgroundColor = Constants.UI.backgroundColor
        backgroundColor = .clear
        containerView.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        containerView.layer.borderWidth = 1
    }
}

private extension JenkinsAction {
    var imageName: String {
        switch self {
        case .cancelQuietDown:
            return "quiet-down"
        case .exit:
            return "exit"
        case .quietDown:
            return "quiet-down-red"
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
            return "Safe Restart"
        }
    }
}
