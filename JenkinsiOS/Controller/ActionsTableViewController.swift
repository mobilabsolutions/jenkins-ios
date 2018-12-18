//
//  ActionsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ActionsTableViewController: UITableViewController, AccountProvidable {
    var account: Account?
    var actions: [JenkinsAction] = [.restart, .safeRestart, .exit, .safeExit, .quietDown, .cancelQuietDown]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none

        setBottomContentInsetForOlderDevices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Actions"

        // Make sure the navigation item does not contain the search bar.
        if #available(iOS 11.0, *) {
            tabBarController?.navigationItem.searchController = nil
        }
    }

    func performAction(action: JenkinsAction) {
        // Methods for presenting messages to the user
        func showSuccessMessage() {
            displayError(title: "Success", message: "The action was completed", textFieldConfigurations: [], actions: [
                UIAlertAction(title: "Alright", style: .cancel, handler: nil),
            ])
        }

        func showFailureMessage(error: Error) {
            displayNetworkError(error: error, onReturnWithTextFields: { data in
                self.account?.password = data["password"]!
                self.account?.username = data["username"]!
                self.performAction(action: action)
            })
        }

        guard let account = account
        else { return }
        // Perform request
        NetworkManager.manager.perform(action: action, on: account) { error in
            DispatchQueue.main.async {
                if let error = error {
                    if let networkManagerError = error as? NetworkManagerError, case let .HTTPResponseNoSuccess(code, _) = networkManagerError, Constants.Networking.successCodes.contains(code) || code == 503 {
                        showSuccessMessage()
                    } else {
                        showFailureMessage(error: error)
                    }
                } else {
                    showSuccessMessage()
                    LoggingManager.loggingManager.logTriggeredAction(action: action)
                }
            }
        }
    }

    // MARK: - Table view delegate and datasource

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.actionCell, for: indexPath) as! ActionTableViewCell
        cell.setup(for: actions[indexPath.row])
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 74
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard account != nil
        else { return }
        verifyAction(action: actions[indexPath.row]) { [unowned self] action in
            self.performAction(action: action)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func verifyAction(action: JenkinsAction, onSuccess completion: @escaping (JenkinsAction) -> Void) {
        let alert = alertWithImage(image: UIImage(named: action.alertImageName), title: action.alertTitle,
                                   message: action.alertMessage, height: 49)
        alert.addAction(UIAlertAction(title: "Yes, do it", style: .default, handler: { _ in completion(action) }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

private extension JenkinsAction {
    var alertTitle: String {
        switch self {
        case .exit:
            return "Exit"
        case .safeExit:
            return "Safe Exit"
        case .quietDown:
            return "Quiet Down"
        case .cancelQuietDown:
            return "Cancel Quiet Down"
        case .restart:
            return "Restart"
        case .safeRestart:
            return "Safe Restart"
        }
    }

    var alertMessage: String {
        let operation: String
        switch self {
        case .exit:
            operation = "shutdown"
        case .safeExit:
            operation = "safely shutdown"
        case .quietDown:
            operation = "quiet down"
        case .cancelQuietDown:
            operation = "cancel quieting down"
        case .restart:
            operation = "restart"
        case .safeRestart:
            operation = "safely restart"
        }

        return "Do you want to \(operation) the server?"
    }

    var alertImageName: String {
        let identifier: String
        switch self {
        case .safeRestart:
            identifier = "safe-restart"
        case .safeExit:
            identifier = "safe-exit"
        case .exit:
            identifier = "exit"
        case .restart:
            identifier = "restart"
        case .quietDown:
            identifier = "quiet-down"
        case .cancelQuietDown:
            identifier = "cancel-quiet-down"
        }

        return "\(identifier)-server-illustration"
    }
}
