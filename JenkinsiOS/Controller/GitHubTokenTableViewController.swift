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

class GitHubTokenTableViewController: UITableViewController, AccountProvidable, VerificationFailureNotifying, DoneButtonEventReceiving {
    var account: Account?
    var accountAdder: AccountAdder?

    weak var verificationFailurePresenter: VerificationFailurePresenting?
    weak var doneButtonContainer: DoneButtonContaining?

    private let githubTokenPage = URL(string: "https://github.com/settings/tokens")
    @IBOutlet var generateTokenButton: UIButton!
    @IBOutlet var tokenTextField: PasswordTextField!
    @IBOutlet var usernameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        generateTokenButton.addTarget(self, action: #selector(generateToken), for: .touchUpInside)
        tokenTextField.addTarget(self, action: #selector(updateDoneButtonState), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(updateDoneButtonState), for: .editingChanged)
        updateDoneButtonState()
        doneButtonContainer?.setDoneButton(title: "SAVE")
        tableView.keyboardDismissMode = .interactive
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))

        tokenTextField.delegate = self
        usernameTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                              bottom: doneButtonContainer?.tableViewOffsetForDoneButton() ?? 0, right: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LoggingManager.loggingManager.logGithubAccountView()
    }

    @objc private func generateToken() {
        guard let githubTokenPage = self.githubTokenPage
        else { return }
        let viewController = SFSafariViewController(url: githubTokenPage)
        present(viewController, animated: true, completion: LoggingManager.loggingManager.logOpenGithubTokenUrl)
    }

    @objc private func updateDoneButtonState() {
        doneButtonContainer?.setDoneButton(enabled: tokenTextField.text != "" && usernameTextField.text != "")
    }

    func doneButtonPressed() {
        addAccount()
    }

    @objc private func addAccount() {
        guard let account = self.account
        else { return }
        let accountToAdd = Account(baseUrl: account.baseUrl, username: usernameTextField.text, password: tokenTextField.text, port: account.port, displayName: account.displayName, trustAllCertificates: account.trustAllCertificates)

        verify(account: accountToAdd) { [weak self] in
            do {
                try self?.accountAdder?.addOrUpdateAccount(account: accountToAdd)
                LoggingManager.loggingManager.logAccountCreation(https: accountToAdd.baseUrl.scheme == "https",
                                                                 allowsEveryCertificate: accountToAdd.trustAllCertificates,
                                                                 github: true, displayName: account.displayName)
            } catch {
                let notification = UIAlertController(title: "An error occurred", message: "The account could not be saved", preferredStyle: .alert)
                notification.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(notification, animated: true, completion: nil)
            }
        }
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    private func verify(account: Account, onSuccess: @escaping () -> Void) {
        doneButtonContainer?.setDoneButton(alpha: 0.7)
        doneButtonContainer?.setDoneButton(title: "Verifying...")

        verificationFailurePresenter?.hideVerificationFailure()

        _ = NetworkManager.manager.verifyAccount(userRequest: UserRequest.userRequestForJobList(account: account)) { error in
            DispatchQueue.main.async { [weak self] in
                self?.doneButtonContainer?.setDoneButton(alpha: 0.7)
                self?.doneButtonContainer?.setDoneButton(title: "SAVE")

                guard let error = error
                else { onSuccess(); return }

                self?.doneButtonContainer?.setDoneButton(enabled: false)
                self?.verificationFailurePresenter?.showVerificationFailure(error: error)
            }
        }
    }
}

extension GitHubTokenTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            usernameTextField.resignFirstResponder()
            tokenTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
