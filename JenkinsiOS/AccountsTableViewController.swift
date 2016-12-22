//
//  AccountsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AccountsTableViewController: BaseTableViewController {
    
    let headers = ["Favorites", "Accounts"]
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        navigationItem.leftBarButtonItem = editButtonItem
        registerForPreviewing(with: self, sourceView: tableView)
        
        emptyTableViewText = "No accounts have been created yet.\nTo create an account, tap on the +"
        emptyTableViewImages = [ UIImage(named: "sadFace")! ]
        
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddAccountViewController)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
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
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath, let dest = segue.destination as? JobsTableViewController, segue.identifier == Constants.Identifiers.showJobsSegue{
            prepare(viewController: dest, indexPath: indexPath)
        }
        else if segue.identifier == Constants.Identifiers.editAccountSegue, let dest = segue.destination as? AddAccountTableViewController, let indexPath = sender as? IndexPath{
            prepare(viewController: dest, indexPath: indexPath)
        }
        navigationController?.isToolbarHidden = true
    }
    
    fileprivate func prepare(viewController: UIViewController, indexPath: IndexPath){
        if let addAccountViewController = viewController as? AddAccountTableViewController{
            addAccountViewController.account = AccountManager.manager.accounts[indexPath.row]
        }
        else if let jobsViewController = viewController as? JobsTableViewController{
            jobsViewController.account = AccountManager.manager.accounts[indexPath.row]
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        tableView.reloadData()
    }
    
    @IBAction func showInformationViewController(){
        performSegue(withIdentifier: Constants.Identifiers.showInformationSegue, sender: nil)
    }
    
    func showAddAccountViewController(){
        performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: nil)
    }
    
    //MARK: - Tableview datasource and delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.accountCell, for: indexPath) as! AccountTableViewCell
            
            let urlString = "\(AccountManager.manager.accounts[indexPath.row].baseUrl)"
            
            cell.accountNameLabel.text = AccountManager.manager.accounts[indexPath.row].displayName ?? urlString
            cell.urlLabel.text = urlString
            
            return cell
        }
        else{
            return tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.favoritesCell, for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : AccountManager.manager.accounts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 1
            else { return }
        
        if isEditing{
            performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: indexPath)
        }
        else{
            performSegue(withIdentifier: Constants.Identifiers.showJobsSegue, sender: indexPath)
        }
    }
    
    override func numberOfSections() -> Int {
        return headers.count
    }
    
    override func tableViewIsEmpty() -> Bool {
        return AccountManager.manager.accounts.count == 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < headers.count ? headers[section] : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
}

extension AccountsTableViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Ugly hack to ensure that a presented popover will not be presented once pushed
        viewControllerToCommit.dismiss(animated: true, completion: nil)
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // The selected table view cell should be selected while we are not editing and should be in the accounts section, instead of the favorites section
        guard let indexPath = tableView.indexPathForRow(at: location), isEditing == false, indexPath.section == 1
            else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        guard let jobsViewController = (UIApplication.shared.delegate as? AppDelegate)?.getViewController(name: "JobsTableViewController")
            else { return nil }
        prepare(viewController: jobsViewController, indexPath: indexPath)
        
        return jobsViewController
    }
}
