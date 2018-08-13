//
//  BuildQueueTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildQueueTableViewController: RefreshingTableViewController, AccountProvidable {

    var account: Account? {
        didSet {
            if account != nil && account != oldValue {
                queue = nil
                tableView.reloadData()
                performRequest()
            }
        }
    }
    
    private var queue: BuildQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Build Queue"
        emptyTableViewText = "Loading Build Queue"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        tableView.backgroundColor = Constants.UI.backgroundColor

        performRequest()

        contentType = .buildQueue
    }

    override func refresh(){
        performRequest()
    }

    func performRequest(){
        
        guard let account = account
            else { return }
        
        emptyTableView(for: .loading)
        
        _ = NetworkManager.manager.getBuildQueue(userRequest: UserRequest.userRequestForBuildQueue(account: account)) { (queue, error) in
            DispatchQueue.main.async {
                guard let queue = queue, error == nil
                    else {
                        if let error = error{
                            self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                                self.account?.username = returnData["username"]!
                                self.account?.password = returnData["password"]!
                                
                                self.performRequest()
                            })
                            self.emptyTableView(for: .error)
                        }
                        return
                }
                
                self.queue = queue
                self.emptyTableView(for: .noData)
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source    
    
    override func tableViewIsEmpty() -> Bool {
        return queue == nil || queue?.items.count == 0
    }
    
    override func numberOfSections() -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.buildQueueCell, for: indexPath) as! BuildQueueTableViewCell
        
        if let item = queue?.items[indexPath.row] {
            cell.queueItem = item
        }
        
        return cell
    }

    override func separatorStyleForNonEmpty() -> UITableViewCellSeparatorStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: queue?.items[indexPath.row])
    }
    
    //MARK: - View controller navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? JobViewController, let queueItem = sender as? QueueItem {
            dest.account = account
            dest.job = queueItem.task
        }
    }

}
