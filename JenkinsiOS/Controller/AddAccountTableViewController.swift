//
//  AddAccountTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol AddAccountTableViewControllerDelegate: class {
    func didEditAccount(account: Account, oldAccount: Account?)
}

protocol VerificationFailurePresenting: class {
    func showVerificationFailure(error: Error)
    func hideVerificationFailure()
}

class AddAccountTableViewController: UITableViewController {

    // MARK: - Instance variables

    var account: Account?

    weak var delegate: AddAccountTableViewControllerDelegate?
    weak var verificationFailurePresenter: VerificationFailurePresenting?

    // MARK: - Outlets

    @IBOutlet var addAccountButton: UIButton!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var apiKeyTextField: UITextField!
    @IBOutlet var portTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var schemeControl: UISegmentedControl!
    @IBOutlet var trustAllCertificatesSwitch: UISwitch!
    @IBOutlet var trustAllCertificatesWarning: UILabel!

    @IBOutlet var topBackgroundView: UIView!
    @IBOutlet var bottomMostBackgroundView: UIView!

    @IBOutlet var textFields: [UITextField]!

    private var actionButtonTitle: String {
        return account != nil ? "SAVE" : "DONE"
    }

    // MARK: - Actions

    @objc func addAccount() {
        guard let account = createAccount()
        else { return }

        verify(account: account, onSuccess: { [weak self] in
            let success = self?.addAccountWith(account: account)
            if success == true {
                LoggingManager.loggingManager.logAccountCreation(https: account.baseUrl.host == "https", allowsEveryCertificate: account.trustAllCertificates)
                self?.delegate?.didEditAccount(account: account, oldAccount: nil)
            }
        })
    }

    private func addAccountWith(account: Account) -> Bool {
        do {
            try AccountManager.manager.addAccount(account: account)
            ApplicationUserManager.manager.save()
            return true
        } catch let error as AccountManagerError {
            displayError(title: "Error", message: error.localizedDescription, textFieldConfigurations: [], actions: [
                UIAlertAction(title: "Alright", style: .cancel, handler: nil),
            ])
        } catch { print("An error occurred: \(error)") }

        return false
    }

    private func createAccount() -> Account? {
        guard let url = createAccountURL()
        else { return nil }

        let port = Int(portTextField.text!)
        let username = usernameTextField.text != "" ? usernameTextField.text : nil
        let password = apiKeyTextField.text != "" ? apiKeyTextField.text : nil

        let displayName = nameTextField.text != "" ? nameTextField.text : nil
        let trustAllCertificates = trustAllCertificatesSwitch.isOn

        return Account(baseUrl: url, username: username, password: password, port: port, displayName: displayName,
                       trustAllCertificates: trustAllCertificates)
    }

    private func createAccountURL() -> URL? {
        let schemeString = schemeControl.titleForSegment(at: schemeControl.selectedSegmentIndex) ?? "https://"
        return URL(string: schemeString + urlTextField.text!)
    }

    @objc func saveAccount() {
        guard let newAccount = createAccount(), let oldAccount = account
        else { return }

        verify(account: newAccount, onSuccess: { [weak self] in
            do {
                try AccountManager.manager.editAccount(newAccount: newAccount, oldAccount: oldAccount)
                self?.delegate?.didEditAccount(account: newAccount, oldAccount: oldAccount)
            } catch {
                print("Could not save account: \(error)")
                let alert = UIAlertController(title: "Error", message: "Could not save the account", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }

    // MARK: - View Controller lifecycle

    override func viewDidLoad() {
        topBackgroundView.layer.cornerRadius = 5
        bottomMostBackgroundView.layer.cornerRadius = 5

        // Write all known data into the text fields
        if let account = account {
            prepareUI(for: account)
        } else {
            prepareUIWithoutAccount()
        }

        // The add button should not be enabled when there is no text in the mandatory textfields
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
        // For every mandatory textfield, add an event handler
        urlTextField.addTarget(self, action: #selector(textFieldChanged), for: .allEditingEvents)
        usernameTextField.addTarget(self, action: #selector(textFieldChanged), for: .allEditingEvents)
        apiKeyTextField.addTarget(self, action: #selector(textFieldChanged), for: .allEditingEvents)
        portTextField.addTarget(self, action: #selector(textFieldChanged), for: .allEditingEvents)

        schemeControl.addTarget(self, action: #selector(toggleTrustAllCertificatesCell), for: .valueChanged)

        toggleTrustAllCertificates(trustAllCertificatesSwitch)

        trustAllCertificatesSwitch.addTarget(self, action: #selector(didToggleTrustAllCertificates), for: .allEditingEvents)

        textFields.forEach { $0.delegate = self }

        addKeyboardHandling()
        toggleTrustAllCertificatesCell()
    }

    private func verify(account: Account, onSuccess: @escaping () -> Void) {
        addAccountButton.alpha = 0.7
        addAccountButton.setTitle("Verifying...", for: .normal)

        verificationFailurePresenter?.hideVerificationFailure()

        _ = NetworkManager.manager.verifyAccount(userRequest: UserRequest.userRequestForJobList(account: account)) { error in
            DispatchQueue.main.async { [weak self] in
                self?.addAccountButton.alpha = 1.0
                self?.addAccountButton.setTitle(self?.actionButtonTitle, for: .normal)

                guard let error = error
                else { onSuccess(); return }

                self?.addAccountButton.isEnabled = false
                self?.verificationFailurePresenter?.showVerificationFailure(error: error)
            }
        }
    }

    @objc private func toggleTrustAllCertificatesCell() {
        if schemeControl.titleForSegment(at: schemeControl.selectedSegmentIndex) == "http://" {
            trustAllCertificatesSwitch.setOn(false, animated: true)
            trustAllCertificatesSwitch.isEnabled = false
        } else {
            trustAllCertificatesSwitch.isEnabled = true
        }
        toggleTrustAllCertificates(trustAllCertificatesSwitch)
    }

    private func addKeyboardHandling() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self]
            notification in
            guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }

            guard let footerViewRect = self?.tableView.tableFooterView?.frame
            else { return }

            let inset = keyboardRect.minY - footerViewRect.minY

            let movedTableViewBy = -inset - 20

            self?.tableView.contentInset.top = (inset > 0) ? movedTableViewBy : 0
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] _ in
            self?.tableView.contentInset.top = 0
        }

        tableView.keyboardDismissMode = .onDrag

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(recognizer)
    }

    @objc private func dismissKeyboard() {
        tableView.endEditing(true)
    }

    @IBAction func toggleTrustAllCertificates(_ sender: UISwitch) {
        trustAllCertificatesWarning.isHidden = !sender.isOn
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
    }

    private func prepareUI(for account: Account) {
        addAccountButton.setTitle(actionButtonTitle, for: .normal)
        addAccountButton.addTarget(self, action: #selector(saveAccount), for: .touchUpInside)
        usernameTextField.text = account.username ?? ""
        apiKeyTextField.text = account.password ?? ""
        urlTextField.text = account.baseUrl.absoluteString.replacingOccurrences(of: account.baseUrl.scheme?.appending("://") ?? "", with: "")
        nameTextField.text = account.displayName ?? ""
        portTextField.text = account.port != nil ? "\(account.port!)" : ""
        schemeControl.selectedSegmentIndex = account.baseUrl.scheme == "http" ? 1 : 0
        trustAllCertificatesSwitch.isOn = account.trustAllCertificates
    }

    private func prepareUIWithoutAccount() {
        addAccountButton.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
        addAccountButton.setTitle(actionButtonTitle, for: .normal)
        usernameTextField.text = ""
        apiKeyTextField.text = ""
        portTextField.placeholder = "Default Port"
    }

    @objc private func didToggleTrustAllCertificates() {
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
    }

    // MARK: - Textfield methods

    @objc private func textFieldChanged() {
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
    }

    func addButtonShouldBeEnabled() -> Bool {
        // Attention: a textField's text property is *never* nil, unless set to nil by the programmer

        // The urlTextField's text should be a valid URL
        // The port text field's text should either be empty or a valid integer

        return urlTextField.text != nil && URL(string: urlTextField.text!) != nil && (portTextField.text == "" || Int(portTextField.text!) != nil)
    }
}

extension AddAccountTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let index = textFields.firstIndex(of: textField), index.advanced(by: 1) < textFields.endIndex {
            textField.resignFirstResponder()
            textFields[index.advanced(by: 1)].becomeFirstResponder()
            return false
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}
