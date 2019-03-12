//
//  ParametersContainerViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 12.03.19.
//  Copyright © 2019 MobiLab Solutions. All rights reserved.
//

import UIKit

class ParametersContainerViewController: UINavigationController {
    var parameters: [Parameter] = [] {
        didSet {
            updateParametersViewController()
        }
    }

    var parametersDelegate: ParametersViewControllerDelegate? {
        didSet {
            updateParametersViewController()
        }
    }

    private func updateParametersViewController() {
        if let parametersViewController = self.viewControllers.first as? ParametersTableViewController {
            parametersViewController.parameters = parameters
            parametersViewController.delegate = parametersDelegate
        }
    }
}
