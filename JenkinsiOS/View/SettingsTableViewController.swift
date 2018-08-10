//
//  SettingsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 07.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, AccountProvidable, CurrentAccountProviding, CurrentAccountProvidingDelegate {
    
    var account: Account? {
        didSet {
            guard let account = account
                else { return }
            sections = [.plugins, .users,
                        .accounts(currentAccountName: account.displayName ?? account.baseUrl.absoluteString)]
            tableView.reloadData()
        }
    }
    
    var currentAccountDelegate: CurrentAccountProvidingDelegate?
    
    private enum SettingsSection {
        case plugins
        case users
        case accounts(currentAccountName: String)
        
        var title: String {
            switch self {
            case .plugins:
                return "PLUGINS"
            case .users:
                return "USERS"
            case .accounts(currentAccountName: _):
                return "ACCOUNTS"
            }
        }
        
        var actionTitle: String {
            switch self {
            case .plugins:
                return "View Plugins"
            case .users:
                return "View Users"
            case .accounts(let currentAccountName):
                return currentAccountName
            }
        }
    }
    
    private var sections: [SettingsSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.title = "Settings"
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 38
        }
        
        return 42
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.headerCell, for: indexPath)
            cell.textLabel?.text = sections[indexPath.section].title
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = Constants.UI.backgroundColor
            cell.textLabel?.backgroundColor = Constants.UI.backgroundColor
            cell.textLabel?.textColor = Constants.UI.greyBlue
            cell.textLabel?.font = UIFont.boldDefaultFont(ofSize: 13)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.settingsCell, for: indexPath) as! BasicTableViewCell
            cell.title = sections[indexPath.section].actionTitle
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0
            else { return }
        
        switch sections[indexPath.section] {
        case .plugins:
            performSegue(withIdentifier: Constants.Identifiers.showPluginsSegue, sender: nil)
        case .users:
            performSegue(withIdentifier: Constants.Identifiers.showUsersSegue, sender: nil)
        case .accounts(_):
            performSegue(withIdentifier: Constants.Identifiers.showAccountsSegue, sender: nil)
        }
    }

    func didChangeCurrentAccount(current: Account) {
        currentAccountDelegate?.didChangeCurrentAccount(current: current)
        account = current
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var dest = segue.destination as? AccountProvidable {
            dest.account = account
        }
        
        if var dest = segue.destination as? CurrentAccountProviding {
            dest.currentAccountDelegate = self
        }
    }

}
