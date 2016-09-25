//
//  AddAccountTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AddAccountTableViewController: UITableViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var addAccountButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    
    //MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func addAccount(){
        guard let url = URL(string: urlTextField.text!)
            else { return }
        let port = Int(portTextField.text!) ?? Constants.Defaults.defaultPort
        let username = usernameTextField.text != "" ? usernameTextField.text : nil
        let password = apiKeyTextField.text != "" ? apiKeyTextField.text : nil
        
        let account = Account(baseUrl: url, username: username, password: password, port: port)
        AccountManager.manager.addAccount(account: account)
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        // The add button should not be enabled when there is no text in the mandatory textfields
        addAccountButton.isEnabled = false
        
        addAccountButton.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
        
        // For every mandatory textfield, add an event handler
        urlTextField.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.allEditingEvents)
        // For username and password textfields, set the default value to nil
        
        usernameTextField.text = nil
        apiKeyTextField.text = nil
    }
    
    //MARK: - Textfield methods
    
    @objc private func textFieldChanged(){
        
        //Attention: a textField's text property is *never* nil, unless set to nil by the programmer

        // The urlTextField's text should be a valid URL0
        guard urlTextField.text != nil && URL(string: urlTextField.text!) != nil
            else { return }
        // The port text field's text should either be empty or a valid integer
        guard portTextField.text == "" || Int(portTextField.text!) != nil
            else { return }
        
        addAccountButton.isEnabled = true
    }
}
