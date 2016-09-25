//
//  AccountsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AccountsTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - Viewcontroller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let account = sender as? Account, let dest = segue.destination as? JobsTableViewController, segue.identifier == Constants.Identifiers.showJobsSegue{
            dest.account = account
        }
    }
    
    //MARK: - Tableview datasource and delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.accountCell, for: indexPath)
        cell.textLabel?.text = "\(AccountManager.manager.accounts[indexPath.row].baseUrl)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountManager.manager.accounts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = AccountManager.manager.accounts[indexPath.row]
        performSegue(withIdentifier: Constants.Identifiers.showJobsSegue, sender: account)
    }
}
