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
    
    @IBOutlet weak var addAccountButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    //MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func addAccount(){
        guard let account = createAccount()
            else { return }
        
        AccountManager.manager.addAccount(account: account)
        ApplicationUserManager.manager.save()
        dismiss(animated: true, completion: nil)
    }
    
    private func createAccount() -> Account?{
        guard let url = URL(string: "https://" + urlTextField.text!)
            else { return nil }
        
        let port = Int(portTextField.text!) ?? Constants.Defaults.defaultPort
        let username = usernameTextField.text != "" ? usernameTextField.text : nil
        let password = apiKeyTextField.text != "" ? apiKeyTextField.text : nil
        
        let displayName = nameTextField.text != "" ? nameTextField.text : nil
        
        return Account(baseUrl: url, username: username, password: password, port: port, displayName: displayName)
    }
    
    func saveAccount(){
        guard let newAccount = createAccount()
            else { return }
        account?.baseUrl = newAccount.baseUrl
        account?.displayName = newAccount.displayName
        account?.password = newAccount.password
        account?.username = newAccount.username
        account?.port = newAccount.port
        
        AccountManager.manager.save()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - View Controller lifecycle
    
    override func viewDidLoad() {

        // Write all known data into the text fields
        if let account = account{
            addAccountButton.setTitle("Save", for: .normal)
            addAccountButton.addTarget(self, action: #selector(saveAccount), for: .touchUpInside)
            usernameTextField.text = account.username ?? ""
            apiKeyTextField.text = account.password ?? ""
            urlTextField.text = account.baseUrl.absoluteString.replacingOccurrences(of: account.baseUrl.scheme?.appending("://") ?? "", with: "")
            nameTextField.text = account.displayName ?? ""
        }
        else{
            addAccountButton.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
            usernameTextField.text = ""
            apiKeyTextField.text = ""
            portTextField.placeholder = "\(Constants.Defaults.defaultPort)"
        }

        // The add button should not be enabled when there is no text in the mandatory textfields
        addAccountButton.isEnabled = addButtonShouldBeEnabled()
        // For every mandatory textfield, add an event handler
        urlTextField.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.allEditingEvents)
        // For username and password textfields, set the default value to nil
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
