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
            if let account = account, !account.isEqual(oldValue) {
                queue = nil
                tableView.reloadData()
                performRequest()
            }
        }
    }

    private var queue: BuildQueue?

    override func viewDidLoad() {
        super.viewDidLoad()
        emptyTableViewText = "Loading Build Queue"

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.backgroundColor = Constants.UI.backgroundColor

        performRequest()
        emptyTableView(for: .loading)

        contentType = .buildQueue

        setBottomContentInsetForOlderDevices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Build Queue"

        // Make sure the navigation item does not contain the search bar.
        if #available(iOS 11.0, *) {
            tabBarController?.navigationItem.searchController = nil
        }
    }

    override func refresh() {
        performRequest()
    }

    func performRequest() {
        guard let account = account
        else { return }

        emptyTableView(for: .loading)

        _ = NetworkManager.manager.getBuildQueue(userRequest: UserRequest.userRequestForBuildQueue(account: account)) { queue, error in
            DispatchQueue.main.async {
                guard let queue = queue, error == nil
                else {
                    if let error = error {
                        self.displayNetworkError(error: error, onReturnWithTextFields: { returnData in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!

                            self.performRequest()
                        })
                        self.emptyTableView(for: .error, action: self.defaultRefreshingAction)
                        self.tableView.reloadData()
                    }
                    return
                }

                self.queue = queue
                self.emptyTableView(for: .noData, action: self.defaultRefreshingAction)
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

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return queue?.items.count ?? 0
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 104
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.buildQueueCell, for: indexPath) as! BuildQueueTableViewCell

        if let item = queue?.items[indexPath.row] {
            cell.queueItem = item
        }

        return cell
    }

    override func separatorStyleForNonEmpty() -> UITableViewCell.SeparatorStyle {
        return .none
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: queue?.items[indexPath.row])
    }

    override func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return (queue?.items[indexPath.row].task?.wasBuilt ?? false) ? indexPath : nil
    }

    // MARK: - View controller navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? JobViewController, let queueItem = sender as? QueueItem {
            dest.account = account
            dest.job = queueItem.task
        }
    }
}
