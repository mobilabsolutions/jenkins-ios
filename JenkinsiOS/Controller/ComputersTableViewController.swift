//
//  ComputersTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ComputersTableViewController: RefreshingTableViewController, AccountProvidable {
    var account: Account? {
        didSet {
            if let account = account, !account.isEqual(oldValue) {
                computerList = nil
                tableView.reloadData()
                performRequest()
            }
        }
    }

    private var computerList: ComputerList?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "BasicImageTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.computerCell)
        tableView.backgroundColor = Constants.UI.backgroundColor

        performRequest()
        emptyTableView(for: .loading)

        contentType = .nodes

        setBottomContentInsetForOlderDevices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Nodes"
    }

    private func performRequest() {
        guard let account = account
        else { return }
        emptyTableView(for: .loading)
        _ = NetworkManager.manager.getComputerList(userRequest: UserRequest.userRequestForComputers(account: account)) { computerList, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayNetworkError(error: error, onReturnWithTextFields: { returnData in
                        self.account?.username = returnData["username"]!
                        self.account?.password = returnData["password"]!

                        self.performRequest()
                    })
                    self.emptyTableView(for: .error, action: self.defaultRefreshingAction)
                } else {
                    self.emptyTableView(for: .noData, action: self.defaultRefreshingAction)
                }

                self.computerList = computerList
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func refresh() {
        computerList = nil
        performRequest()
    }

    // MARK: - Tableview data source and delegate

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return computerList?.computers.count ?? 0
    }

    override func tableViewIsEmpty() -> Bool {
        return (computerList?.computers.count ?? 0) == 0
    }

    override func numberOfSections() -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.computerCell, for: indexPath) as! BasicImageTableViewCell
        cell.iconImageView.image = UIImage(named: "nodesCellImage")
        cell.titleLabel.text = computerList?.computers[indexPath.row].displayName ?? "Node #\(indexPath.row)"
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 74
    }

    override func separatorStyleForNonEmpty() -> UITableViewCell.SeparatorStyle {
        return .none
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.showComputerSegue, sender: computerList?.computers[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ComputerTableViewController, let computer = sender as? Computer {
            dest.computer = computer
        }
    }
}
