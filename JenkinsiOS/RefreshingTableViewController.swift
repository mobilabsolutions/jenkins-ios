//
// Created by Robert on 27.10.16.
// Copyright (c) 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class RefreshingTableViewController: UITableViewController {
    override func viewDidLoad(){
        super.viewDidLoad()
        addRefreshControl(action: #selector(refresh))
    }

    func refresh(){}

    /// Add a refresh control to the given table view controller
    ///
    /// - parameter action: The action that should be taken once the user tries to refresh
    private func addRefreshControl(action: Selector){
        let refreshControl = UIRefreshControl()
        self.refreshControl = refreshControl
        refreshControl.tintColor = UIColor(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1.0)
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
}
