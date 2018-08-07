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
    var actions: [JenkinsAction] = JenkinsAction.allCases
    
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
                }
            }
        }
    }
    
    // MARK: - Table view delegate and datasource
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard account != nil
            else { return }
        performAction(action: actions[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
