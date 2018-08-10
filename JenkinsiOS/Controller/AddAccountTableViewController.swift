//
//  AddAccountTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol AddAccountTableViewControllerDelegate: class {
    func didEditAccount(account: Account)
}

class AddAccountTableViewController: UITableViewController {
    
    //MARK: - Instance variables
    
    var account: Account?
    
    weak var delegate: AddAccountTableViewControllerDelegate?
    
    //MARK: - Outlets
    
    @IBOutlet weak var addAccountButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var schemeControl: UISegmentedControl!
    @IBOutlet weak var trustAllCertificatesSwitch: UISwitch!
    @IBOutlet weak var trustAllCertificatesWarning: UILabel!

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomMostBackgroundView: UIView!
    
    //MARK: - Actions
    
    @objc func addAccount(){
        guard let account = createAccount()
            else { return }
        let success = addAccountWith(account: account)
        if success {
            LoggingManager.loggingManager.logAccountCreation(https: account.baseUrl.host == "https", allowsEveryCertificate: account.trustAllCertificates)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func addAccountWith(account: Account) -> Bool {
        do {
            try AccountManager.manager.addAccount(account: account)
            ApplicationUserManager.manager.save()
            return true
        }
        catch let error as AccountManagerError {
            displayError(title: "Error", message: error.localizedDescription, textFieldConfigurations: [], actions: [
                    UIAlertAction(title: "Alright", style: .cancel, handler: nil)
                ])
        }
        catch { print("An error occurred: \(error)") }
        
        return false
    }
    
    private func createAccount() -> Account?{
        
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
    
    private func createAccountURL() -> URL?{
        let schemeString = schemeControl.titleForSegment(at: schemeControl.selectedSegmentIndex) ?? "https://"
        return URL(string: schemeString + urlTextField.text!)
    }
    
    @objc func saveAccount(){
        guard let newAccount = createAccount()
            else { return }
        
        var didDeleteOldAccount = false
        let oldAccount = account?.copy() as! Account?
        
        if let account = account, newAccount.baseUrl != account.baseUrl {
            do {
                try AccountManager.manager.deleteAccount(account: account)
                didDeleteOldAccount = true
            }
            catch {
                print(error)
            }
        }
        
        account?.displayName = newAccount.displayName
        account?.password = newAccount.password
        account?.username = newAccount.username
        account?.port = newAccount.port
        account?.trustAllCertificates = newAccount.trustAllCertificates
        account?.baseUrl = newAccount.baseUrl
        
        if didDeleteOldAccount, let account = account {
            let success = addAccountWith(account: account)
            
            if !success {
                if let oldAccount = oldAccount{
                    _ = try? AccountManager.manager.addAccount(account: oldAccount)
                }
                return
            }
        }
        else if let account = account {
            delegate?.didEditAccount(account: account)
            AccountManager.manager.save()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View Controller lifecycle
    
    override func viewDidLoad() {

        topBackgroundView.layer.cornerRadius = 5
        bottomMostBackgroundView.layer.cornerRadius = 5
        
        // Write all known data into the text fields
        if let account = account {
            prepareUI(for: account)
        }
        else {
            prepareUIWithoutAccount()
        }

        // The add button should not be enabled when there is no text in the mandatory textfields
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
        // For every mandatory textfield, add an event handler
        urlTextField.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.allEditingEvents)
    
        schemeControl.addTarget(self, action: #selector(toggleTrustAllCertificatesCell), for: UIControlEvents.valueChanged)
        
        toggleTrustAllCertificates(trustAllCertificatesSwitch)
        addKeyboardHandling()
        toggleTrustAllCertificatesCell()
    }
    
    @objc private func toggleTrustAllCertificatesCell(){
        if schemeControl.titleForSegment(at: schemeControl.selectedSegmentIndex) == "http://" {
            self.trustAllCertificatesSwitch.setOn(false, animated: true)
            self.trustAllCertificatesSwitch.isEnabled = false
        }
        else {
            self.trustAllCertificatesSwitch.isEnabled = true
        }
        toggleTrustAllCertificates(trustAllCertificatesSwitch)
    }
    
    private func addKeyboardHandling(){
        
        var movedBy: CGFloat = 0.0
        
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil){
            notification in
            guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                else { return }
            
            guard let footerViewRect = self.tableView.tableFooterView?.frame
                else { return }
            
            let inset =  keyboardRect.minY - footerViewRect.minY
            
            movedBy = -inset - 20
            
            self.tableView.contentInset.top = (inset > 0) ? movedBy : 0
        }
        
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { (notification) in
            self.tableView.contentInset.top = -movedBy
        }
        
        tableView.keyboardDismissMode = .onDrag
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(recognizer)
    }
    
    @objc private func dismissKeyboard(){
        tableView.endEditing(true)
    }
    
    @IBAction func toggleTrustAllCertificates(_ sender: UISwitch) {
        trustAllCertificatesWarning.isHidden = !sender.isOn
    }
    
    private func prepareUI(for account: Account){
        addAccountButton.setTitle("SAVE", for: .normal)
        addAccountButton.addTarget(self, action: #selector(saveAccount), for: .touchUpInside)
        usernameTextField.text = account.username ?? ""
        apiKeyTextField.text = account.password ?? ""
        urlTextField.text = account.baseUrl.absoluteString.replacingOccurrences(of: account.baseUrl.scheme?.appending("://") ?? "", with: "")
        nameTextField.text = account.displayName ?? ""
        portTextField.text = account.port != nil ? "\(account.port!)" : ""
        schemeControl.selectedSegmentIndex = account.baseUrl.scheme == "http" ? 1 : 0
        trustAllCertificatesSwitch.isOn = account.trustAllCertificates
    }
    
    private func prepareUIWithoutAccount(){
        addAccountButton.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
        addAccountButton.setTitle("DONE", for: .normal)
        usernameTextField.text = ""
        apiKeyTextField.text = ""
        portTextField.placeholder = "Default Port"
    }
    
    //MARK: - Textfield methods
    
    @objc private func textFieldChanged(){
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
    }
    
    func addButtonShouldBeEnabled() -> Bool{
        //Attention: a textField's text property is *never* nil, unless set to nil by the programmer
        
        // The urlTextField's text should be a valid URL
        // The port text field's text should either be empty or a valid integer

        return urlTextField.text != nil && URL(string: urlTextField.text!) != nil && (portTextField.text == "" || Int(portTextField.text!) != nil)
    }
}
