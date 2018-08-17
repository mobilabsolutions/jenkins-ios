//
//  PluginsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class PluginsTableViewController: RefreshingTableViewController, AccountProvidable {

    var account: Account? {
        didSet {
            if oldValue == nil && account != nil && pluginList == nil {
                performRequest()
            }
        }
    }
    
    private var pluginList: PluginList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Plugins"
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none
        emptyTableView(for: .loading)
        performRequest()
    }

    override func refresh(){
        performRequest()
    }

    @objc private func performRequest(){
        
        guard let account = account
            else { return }
        
        _ = NetworkManager.manager.getPlugins(userRequest: UserRequest.userRequestForPlugins(account: account)) { (pluginList, error) in
            
            DispatchQueue.main.async {
                guard error == nil
                    else {
                        self.displayNetworkError(error: error!, onReturnWithTextFields: { (returnData) in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!
                        
                            self.performRequest()
                        })
                        self.emptyTableView(for: .error)
                        return
                }
                
                self.pluginList = pluginList
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.emptyTableView(for: .noData)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PluginTableViewController, let plugin = sender as? Plugin {
            dest.plugin = plugin
            dest.allPlugins = self.pluginList?.plugins ?? []
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections() -> Int {
        return 2
    }

    override func tableViewIsEmpty() -> Bool {
        return pluginList?.plugins.isEmpty ?? true
    }
    
    override func separatorStyleForNonEmpty() -> UITableViewCellSeparatorStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : pluginList?.plugins.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.headerCell, for: indexPath)
            cell.textLabel?.text = "PLUGINS INSTALLED"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.pluginCell, for: indexPath) as! BasicTableViewCell
        cell.nextImageType = .next
        cell.title = pluginList?.plugins[indexPath.row].shortName ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 48 : 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.showPluginSegue, sender: pluginList?.plugins[indexPath.row])
    }
}
