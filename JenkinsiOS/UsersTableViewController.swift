//
//  UsersTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class UsersTableViewController: RefreshingTableViewController {

    var account: Account?
    private var userList: UserList?{
        didSet{
            guard let userList = userList
                else { return }
            
            userData = userList.users.map({ (user) -> [(String, String)] in
                return [
                    ("Name", user.fullName),
                    ("Project", user.project?.name ?? "No project")
                ]
            })
        }
    }
    
    private var userData: [[(String, String)]] = []

    
    //MARK: - View controller life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performRequest()
    }

    override func refresh(){
        performRequest()
    }

    //MARK: - Data loading
    @objc private func performRequest(){
        guard let account = account
            else { return }
        
        _ = NetworkManager.manager.getUsers(userRequest: UserRequest.userRequestForUsers(account: account)) { (userList, error) in
            DispatchQueue.main.async {
                if let error = error{
                    self.displayNetworkError(error: error, onReturnWithTextFields: { (returnDict) in
                        self.account?.username = returnDict["username"]!
                        self.account?.password = returnDict["password"]!
                        
                        self.performRequest()
                    })
                }
                
                self.userList = userList
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    //MARK: - Tableview delegate and data source
    
    override func numberOfSections() -> Int {
        return userList?.users.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.userCell, for: indexPath)
        cell.textLabel?.text = userData[indexPath.section][indexPath.row].0
        cell.detailTextLabel?.text = userData[indexPath.section][indexPath.row].1
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return userList?.users[section].fullName
    }
}
