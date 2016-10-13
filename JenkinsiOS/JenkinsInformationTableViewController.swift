//
//  JenkinsInformationTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JenkinsInformationTableViewController: UITableViewController {

    var account: Account?
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showComputersSegue, let dest = segue.destination as? ComputersTableViewController{
            dest.account = account
        }
        else if segue.identifier == Constants.Identifiers.showPluginsSegue, let dest = segue.destination as? PluginsTableViewController{
            dest.account = account
        }
        else if segue.identifier == Constants.Identifiers.showUsersSegue, let dest = segue.destination as? UsersTableViewController{
            dest.account = account
        }
    }
}
