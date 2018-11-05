//
//  AddAccountContainerViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 05.11.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class AddAccountContainerViewController: UIViewController, VerificationFailurePresenting {
    var account: Account?
    var delegate: AddAccountTableViewControllerDelegate?

    private var errorBanner: ErrorBanner?

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let addAccountViewController = segue.destination as? AddAccountTableViewController {
            addAccountViewController.account = account
            addAccountViewController.delegate = delegate
            addAccountViewController.verificationFailurePresenter = self
        }
    }

    func showVerificationFailure(error: Error) {
        let banner = ErrorBanner()

        switch error {
        case let NetworkManagerError.HTTPResponseNoSuccess(code, _) where code == 401 || code == 403:
            banner.errorDetails = "The username or password entered are incorrect.\nPlease confirm that the values are correct"
        default:
            banner.errorDetails = "Something failed!\nPlease confirm that the fields below are filled correctly"
        }

        view.addSubview(banner)

        banner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            banner.leftAnchor.constraint(equalTo: view.leftAnchor),
            banner.rightAnchor.constraint(equalTo: view.rightAnchor),
            banner.widthAnchor.constraint(equalTo: view.widthAnchor),
            banner.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
        ])

        errorBanner = banner
    }

    func hideVerificationFailure() {
        hideErrorBanner()
    }

    private func hideErrorBanner() {
        guard let errorBanner = errorBanner
        else { return }

        errorBanner.layoutIfNeeded()
        errorBanner.heightAnchor.constraint(equalToConstant: 0).isActive = true

        UIView.animate(withDuration: 0.1, animations: {
            errorBanner.layoutIfNeeded()
            errorBanner.alpha = 0.2
        }) { _ in
            errorBanner.removeFromSuperview()
            self.errorBanner = nil
        }
    }
}
