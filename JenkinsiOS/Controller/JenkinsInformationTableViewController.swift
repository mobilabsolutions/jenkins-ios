//
//  JenkinsInformationTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JenkinsInformationTableViewController: UITableViewController, AccountProvidable {

    var account: Account?
    var actions: [JenkinsAction] = [.restart, .safeRestart, .exit, .safeExit, .quietDown, .cancelQuietDown]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Constants.UI.backgroundColor
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Actions"
    }
    
    func performAction(action: JenkinsAction) {
        
        // Methods for presenting messages to the user
        func showSuccessMessage(){
            self.displayError(title: "Success", message: "The action was completed", textFieldConfigurations: [], actions: [
                UIAlertAction(title: "Alright", style: .cancel, handler: nil)
                ])
        }
        
        func showFailureMessage(error: Error){
            self.displayNetworkError(error: error, onReturnWithTextFields: { (data) in
                self.account?.password = data["password"]!
                self.account?.username = data["username"]!
                self.performAction(action: action)
            })
        }
        
        guard let account = account
            else { return }
        // Perform request
        NetworkManager.manager.perform(action: action, on: account) { (error) in
            DispatchQueue.main.async {
                if let error = error{
                    if let networkManagerError = error as? NetworkManagerError, case let .HTTPResponseNoSuccess(code, _) = networkManagerError, Constants.Networking.successCodes.contains(code) || code == 503{
                        showSuccessMessage()
                    }
                    else {
                        showFailureMessage(error: error)
                    }
                }
                else{
                    showSuccessMessage()
                    LoggingManager.loggingManager.logTriggeredAction(action: action)
                }
            }
        }
    }
    
    // MARK: - Table view delegate and datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.actionCell, for: indexPath) as! ActionTableViewCell
        cell.setup(for: actions[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard account != nil
            else { return }
        performAction(action: actions[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
