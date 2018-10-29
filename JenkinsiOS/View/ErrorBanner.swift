//
//  ErrorBanner.swift
//  JenkinsiOS
//
//  Created by Robert on 29.10.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class ErrorBanner: UIView {
    var errorDetails: String = "" {
        didSet {
            errorDetailsLabel?.text = errorDetails
        }
    }

    private var errorDetailsLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = Constants.UI.grapefruit
        addErrorLabel()
    }

    private func addErrorLabel() {
        let label = UILabel(frame: bounds)
        label.textColor = .white
        label.textAlignment = .center
        label.font = label.font.withSize(13)
        label.numberOfLines = 0

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
        ])

        errorDetailsLabel = label
    }
}
