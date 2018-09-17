//
//  AccountCreatedViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 21.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol AccountCreatedViewControllerDelegate {
    func doneButtonPressed()
}

class AccountCreatedViewController: UIViewController {
    var delegate: AccountCreatedViewControllerDelegate?

    @IBOutlet var doneButton: BigButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.UI.backgroundColor
        doneButton.setTitle("DONE", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }

    @objc private func doneButtonPressed() {
        delegate?.doneButtonPressed()
    }
}
