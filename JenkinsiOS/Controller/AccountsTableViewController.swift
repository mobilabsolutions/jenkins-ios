//
//  AccountsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    private let headers = ["Accounts"]

    private var hasAccounts: Bool {
        return AccountManager.manager.accounts.isEmpty == false
    }

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        navigationItem.rightBarButtonItem = editButtonItem
        registerForPreviewing(with: self, sourceView: tableView)

        emptyTableViewText = "No accounts have been created yet.\nTo create an account, tap on the + below"
        emptyTableViewImages = [UIImage(named: "plus")!]

        title = "Accounts"

        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddAccountViewController)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }

    // MARK: - View controller navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath, let _ = segue.destination as? AccountProvidable, segue.identifier == Constants.Identifiers.showJobsSegue {
            prepare(viewController: segue.destination, indexPath: indexPath)
        } else if segue.identifier == Constants.Identifiers.editAccountSegue, let dest = segue.destination as? AddAccountTableViewController, let indexPath = sender as? IndexPath {
            prepare(viewController: dest, indexPath: indexPath)
        }

        navigationController?.isToolbarHidden = true
    }

    fileprivate func prepare(viewController: UIViewController, indexPath: IndexPath) {
        if let addAccountViewController = viewController as? AddAccountTableViewController {
            addAccountViewController.account = AccountManager.manager.accounts[indexPath.row]
        } else if var accountProvidable = viewController as? AccountProvidable {
            accountProvidable.account = AccountManager.manager.accounts[indexPath.row]
        }
    }

    @objc func showAddAccountViewController() {
        performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: nil)
    }

    // MARK: - Tableview datasource and delegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.accountCell, for: indexPath) as! AccountTableViewCell

        let urlString = "\(AccountManager.manager.accounts[indexPath.row].baseUrl)"

        cell.accountNameLabel.text = AccountManager.manager.accounts[indexPath.row].displayName ?? urlString
        cell.urlLabel.text = urlString

        return cell
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return AccountManager.manager.accounts.count
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: indexPath)
        } else {
            performSegue(withIdentifier: Constants.Identifiers.showJobsSegue, sender: indexPath)
        }
    }

    override func numberOfSections() -> Int {
        return headers.count
    }

    override func tableViewIsEmpty() -> Bool {
        return AccountManager.manager.accounts.count == 0
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < headers.count ? headers[section] : nil
    }

    override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && !hasAccounts {
            return 0
        }

        return 50
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && !hasAccounts {
            return 0
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    override func tableView(_: UITableView, shouldIndentWhileEditingRowAt _: IndexPath) -> Bool {
        return false
    }

    override func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { _, indexPath in
                do {
                    try AccountManager.manager.deleteAccount(account: AccountManager.manager.accounts[indexPath.row])
                    self.tableView.reloadData()
                } catch {
                    self.displayError(title: "Error", message: "Something went wrong", textFieldConfigurations: [], actions: [
                        UIAlertAction(title: "Alright", style: .cancel, handler: nil),
                    ])
                    self.tableView.reloadData()
                }
            }),
            UITableViewRowAction(style: .normal, title: "Edit", handler: { _, indexPath in
                self.performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: indexPath)
            }),
        ]
    }
}

extension AccountsViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Ugly hack to ensure that a presented popover will not be presented once pushed
        viewControllerToCommit.dismiss(animated: true, completion: nil)
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), !isEditing
        else { return nil }

        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        return getJobsViewController(for: indexPath)
    }

    private func getJobsViewController(for indexPath: IndexPath) -> UIViewController? {
        guard let jobsViewController = (UIApplication.shared.delegate as? AppDelegate)?.getViewController(name: "JobsTableViewController")
        else { return nil }
        prepare(viewController: jobsViewController, indexPath: indexPath)

        return jobsViewController
    }
}
