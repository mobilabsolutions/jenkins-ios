//
//  AddAccountTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AddAccountTableViewController: UITableViewController {
    
    //MARK: - Instance variables
    
    var account: Account?
    
    //MARK: - Outlets
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var addAccountButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var schemeControl: UISegmentedControl!
    @IBOutlet weak var trustAllCertificatesSwitch: UISwitch!
    @IBOutlet weak var trustAllCertificatesWarning: UILabel!

    //MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func addAccount(){
        guard let account = createAccount()
            else { return }
        
        AccountManager.manager.addAccount(account: account)
        ApplicationUserManager.manager.save()
        performSegue(withIdentifier: Constants.Identifiers.didAddAccountSegue, sender: nil)
    }
    
    private func createAccount() -> Account?{
        
        guard let url = createAccountURL()
            else { return nil }
        
        let port = Int(portTextField.text!) ?? Constants.Defaults.defaultPort
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
    
    func saveAccount(){
        guard let newAccount = createAccount()
            else { return }
        
        var didDeleteOldAccount = false
        
        if let account = account, newAccount.baseUrl != account.baseUrl {
            do{
                try AccountManager.manager.deleteAccount(account: account)
                didDeleteOldAccount = true
            }
            catch{
                print(error)
            }
        }
        
        account?.displayName = newAccount.displayName
        account?.password = newAccount.password
        account?.username = newAccount.username
        account?.port = newAccount.port
        account?.trustAllCertificates = newAccount.trustAllCertificates
        account?.baseUrl = newAccount.baseUrl
        
        if didDeleteOldAccount, let account = account{
            AccountManager.manager.addAccount(account: account)
        }
        else{
            AccountManager.manager.save()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - View Controller lifecycle
    
    override func viewDidLoad() {

        // Write all known data into the text fields
        if let account = account{
            prepareUI(for: account)
        }
        else{
            prepareUIWithoutAccount()
        }

        // The add button should not be enabled when there is no text in the mandatory textfields
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
        // For every mandatory textfield, add an event handler
        urlTextField.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.allEditingEvents)
        
        toggleTrustAllCertificates(trustAllCertificatesSwitch)
        addKeyboardHandling()
    }
    
    private func addKeyboardHandling(){
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil){
            notification in
            guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                else { return }
            
            guard let footerViewRect = self.tableView.tableFooterView?.frame
                else { return }
            
            let inset =  keyboardRect.minY - footerViewRect.minY
            
            self.tableView.contentInset.top = (inset > 0) ? -inset - 20 : 0
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
        addAccountButton.setTitle("Save", for: .normal)
        addAccountButton.addTarget(self, action: #selector(saveAccount), for: .touchUpInside)
        usernameTextField.text = account.username ?? ""
        apiKeyTextField.text = account.password ?? ""
        urlTextField.text = account.baseUrl.absoluteString.replacingOccurrences(of: account.baseUrl.scheme?.appending("://") ?? "", with: "")
        nameTextField.text = account.displayName ?? ""
        titleLabel.text = "Edit Account"
        trustAllCertificatesSwitch.isOn = account.trustAllCertificates
    }
    
    private func prepareUIWithoutAccount(){
        addAccountButton.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
        usernameTextField.text = ""
        apiKeyTextField.text = ""
        portTextField.placeholder = "\(Constants.Defaults.defaultPort)"
        titleLabel.text = "Add account"
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
