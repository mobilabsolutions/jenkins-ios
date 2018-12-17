//
//  GitHubTokenContainerViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 03.12.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class GitHubTokenContainerViewController: AddAccountContainerViewController {
    var accountAdder: AccountAdder?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let dest = segue.destination as? GitHubTokenTableViewController {
            dest.accountAdder = accountAdder
            dest.doneButtonContainer = self
            doneButtonEventReceiver = dest
        }
    }
}
