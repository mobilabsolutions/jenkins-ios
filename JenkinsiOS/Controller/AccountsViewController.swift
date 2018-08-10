//
//  AccountsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol CurrentAccountProviding {
    var account: Account? { get }
    var currentAccountDelegate: CurrentAccountProvidingDelegate? { get set }
}

protocol CurrentAccountProvidingDelegate: class {
    func didChangeCurrentAccount(current: Account)
}

class AccountsViewController: UIViewController, AccountProvidable, UITableViewDelegate, UITableViewDataSource,
                                CurrentAccountProviding, AddAccountTableViewControllerDelegate {
    
    weak var currentAccountDelegate: CurrentAccountProvidingDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newAccountButton: BigButton!
    
    var account: Account?
    
    private var hasAccounts: Bool {
        return AccountManager.manager.accounts.isEmpty == false
    }
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = Constants.UI.backgroundColor
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        self.title = "Accounts"
        
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.tableHeaderView?.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none
        
        newAccountButton.addTarget(self, action: #selector(showAddAccountViewController), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.reloadData()
    }
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.editAccountSegue, let dest = segue.destination as? AddAccountTableViewController, let indexPath = sender as? IndexPath{
            prepare(viewController: dest, indexPath: indexPath)
        }

        navigationController?.isToolbarHidden = true
    }
    
    fileprivate func prepare(viewController: UIViewController, indexPath: IndexPath){
        if let addAccountViewController = viewController as? AddAccountTableViewController{
            addAccountViewController.account = AccountManager.manager.accounts[indexPath.row]
            addAccountViewController.delegate = self
        }
    }
    
    @objc func showAddAccountViewController(){
        performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: nil)
    }
    
    func didEditAccount(account: Account) {
        if account.baseUrl == self.account?.baseUrl {
            // The current account was edited
            currentAccountDelegate?.didChangeCurrentAccount(current: account)
        }
    }
    
    //MARK: - Tableview datasource and delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.accountCell, for: indexPath) as! BasicTableViewCell
        
        let account = AccountManager.manager.accounts[indexPath.row]
        
        cell.title = AccountManager.manager.accounts[indexPath.row].displayName ?? account.baseUrl.absoluteString
        
        if isEditing {
            cell.nextImageType = .next
            cell.selectionStyle = .default
        }
        else {
            cell.nextImageType = account.baseUrl == self.account?.baseUrl ? .checkmark : .none
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountManager.manager.accounts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAccount = AccountManager.manager.accounts[indexPath.row]
        
        if isEditing {
            performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: indexPath)
        }
        else if selectedAccount.baseUrl != account?.baseUrl {
            account = selectedAccount
            currentAccountDelegate?.didChangeCurrentAccount(current: selectedAccount)
            AccountManager.manager.currentAccount = selectedAccount
            tableView.reloadSections([0], with: .automatic)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasAccounts ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && !hasAccounts {
            return 0
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { (_, indexPath) in
                do{
                    try AccountManager.manager.deleteAccount(account: AccountManager.manager.accounts[indexPath.row])
                    self.tableView.reloadData()
                }
                catch{
                    self.displayError(title: "Error", message: "Something went wrong", textFieldConfigurations: [], actions: [
                            UIAlertAction(title: "Alright", style: .cancel, handler: nil)
                        ])
                    self.tableView.reloadData()
                }
            }),
            UITableViewRowAction(style: .normal, title: "Edit", handler: { (_, indexPath) in
                self.performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: indexPath)
            })
        ]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
}
