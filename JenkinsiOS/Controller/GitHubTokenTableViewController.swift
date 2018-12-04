//
//  GitHubTokenTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 03.12.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import SafariServices
import UIKit

protocol AccountAdder {
    func addOrUpdateAccount(account: Account) throws
}

class GitHubTokenTableViewController: UITableViewController, AccountProvidable, VerificationFailureNotifying {
    var verificationFailurePresenter: VerificationFailurePresenting?
    var account: Account?
    var accountAdder: AccountAdder?

    private let githubTokenPage = URL(string: "https://github.com/settings/tokens")
    @IBOutlet var generateTokenButton: UIButton!
    @IBOutlet var tokenTextField: PasswordTextField!
    @IBOutlet var usernameTextField: UITextField!

    @IBOutlet var doneButton: BigButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        generateTokenButton.addTarget(self, action: #selector(generateToken), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
        tokenTextField.addTarget(self, action: #selector(updateDoneButtonState), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(updateDoneButtonState), for: .editingChanged)
        updateDoneButtonState()
        doneButton.setTitle("SAVE", for: .normal)
    }

    @objc private func generateToken() {
        guard let githubTokenPage = self.githubTokenPage
        else { return }
        let viewController = SFSafariViewController(url: githubTokenPage)
        present(viewController, animated: true, completion: nil)
    }

    @objc private func updateDoneButtonState() {
        doneButton.isEnabled = tokenTextField.text != "" && usernameTextField.text != ""
    }

    @objc private func addAccount() {
        guard let account = self.account
        else { return }
        let accountToAdd = Account(baseUrl: account.baseUrl, username: usernameTextField.text, password: tokenTextField.text, port: account.port, displayName: account.displayName, trustAllCertificates: account.trustAllCertificates)

        verify(account: accountToAdd) { [weak self] in
            do {
                try self?.accountAdder?.addOrUpdateAccount(account: accountToAdd)
            } catch {
                let notification = UIAlertController(title: "An error occurred", message: "The account could not be saved", preferredStyle: .alert)
                notification.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(notification, animated: true, completion: nil)
            }
        }
    }

    private func verify(account: Account, onSuccess: @escaping () -> Void) {
        doneButton.alpha = 0.7
        doneButton.setTitle("Verifying...", for: .normal)

        verificationFailurePresenter?.hideVerificationFailure()

        _ = NetworkManager.manager.verifyAccount(userRequest: UserRequest.userRequestForJobList(account: account)) { error in
            DispatchQueue.main.async { [weak self] in
                self?.doneButton.alpha = 1.0
                self?.doneButton.setTitle("SAVE", for: .normal)

                guard let error = error
                else { onSuccess(); return }

                self?.doneButton.isEnabled = false
                self?.verificationFailurePresenter?.showVerificationFailure(error: error)
            }
        }
    }
}
