//
//  ActionsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ActionsCollectionViewController: UICollectionViewController, AccountProvidable {
    var account: Account?
    var actions: [JenkinsAction] = [.restart, .safeRestart, .exit, .safeExit, .quietDown, .cancelQuietDown]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = Constants.UI.backgroundColor
        collectionView.collectionViewLayout = createFlowLayout()
        collectionView.register(UINib(nibName: "ActionHeaderCollectionReusableView", bundle: .main),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Constants.Identifiers.actionHeader)
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

    // MARK: - Collection view delegate and datasource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return actions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.actionCell, for: indexPath) as! ActionCollectionViewCell
        cell.setup(for: actions[indexPath.row])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader
        else { fatalError("Only section header supported as supplementary view") }

        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Identifiers.actionHeader, for: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard account != nil
        else { return }
        verifyAction(action: actions[indexPath.row]) { [unowned self] action in
            self.performAction(action: action)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    private func verifyAction(action: JenkinsAction, onSuccess completion: @escaping (JenkinsAction) -> Void) {
        let alert = alertWithImage(image: UIImage(named: action.alertImageName), title: action.alertTitle,
                                   message: action.alertMessage, height: 49)
        alert.addAction(UIAlertAction(title: "Yes, do it", style: .default, handler: { _ in completion(action) }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    private func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 7
        let width = (view.frame.width - 3 * layout.minimumInteritemSpacing) / 2.0
        let height: CGFloat = 70.0
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        layout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 220)
        return layout
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
