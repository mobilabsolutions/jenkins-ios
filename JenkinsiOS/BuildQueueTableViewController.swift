//
//  BuildQueueTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildQueueTableViewController: UITableViewController {

    var queue: BuildQueue?
    var account: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Build Queue"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        addRefreshControl(action: #selector(performRequest))
        
        performRequest()
    }

    func performRequest(){
        
        guard let account = account
            else { return }
        
        NetworkManager.manager.getBuildQueue(userRequest: UserRequest.userRequestForBuildQueue(account: account)) { (queue, error) in
            guard let queue = queue, error == nil
                else {
                    if let error = error{
                        self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!
                            
                            self.performRequest()
                        })
                    }
                    return
            }
            self.queue = queue
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue?.items.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.buildCell, for: indexPath)
        
        cell.textLabel?.text = queue?.items[indexPath.row].task?.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byCharWrapping
        
        if let colorString = queue?.items[indexPath.row].task?.color?.rawValue{
            cell.imageView?.image = UIImage(named: "\(colorString)Circle")
        }
        
        cell.detailTextLabel?.text = queue?.items[indexPath.row].why
        
        return cell
    }

    //MARK: - View controller navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? JobViewController, let cell = sender as? UITableViewCell, let index = tableView.indexPath(for: cell){
            dest.account = account
            dest.job = queue?.items[index.row].task
        }
    }

}
