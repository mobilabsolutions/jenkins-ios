//
//  UsersTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class UsersTableViewController: RefreshingTableViewController, AccountProvidable {

    var account: Account? {
        didSet {
            if oldValue == nil && account != nil && userList == nil {
                performRequest()
            }
        }
    }
    
    private var userList: UserList?

    
    //MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Users"
        
        self.tableView.register(UINib(nibName: "UserTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.userCell)
        self.tableView.backgroundColor = Constants.UI.backgroundColor
        self.tableView.separatorStyle = .none
        
        emptyTableView(for: .loading)
    }
    
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
                self.emptyTableView(for: .noData)
                if let error = error{
                    self.displayNetworkError(error: error, onReturnWithTextFields: { (returnDict) in
                        self.account?.username = returnDict["username"]!
                        self.account?.password = returnDict["password"]!
                        
                        self.performRequest()
                    })
                    self.emptyTableView(for: .error)
                }
                
                self.userList = userList
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? UserViewController, let user = sender as? User {
            dest.user = user
        }
    }
    
    //MARK: - Tableview delegate and data source
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func separatorStyleForNonEmpty() -> UITableViewCell.SeparatorStyle {
        return .none
    }
    
    override func tableViewIsEmpty() -> Bool {
        return (userList?.users.count ?? 0) == 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList?.users.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.userCell, for: indexPath) as! UserTableViewCell
        cell.user = userList?.users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.showUserSegue, sender: userList?.users[indexPath.row])
    }
}
