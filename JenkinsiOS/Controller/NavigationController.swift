//
//  NavigationController.swift
//  JenkinsiOS
//
//  Created by Robert on 17.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, AccountProvidable {
    
    var account: Account? {
        didSet {
            if var accountProvidableViewController = self.viewControllers.first as? AccountProvidable {
                accountProvidableViewController.account = account
            }
        }
    }
    
    override var isNavigationBarHidden: Bool{
        get {
            return false
        }
        set {}
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(false, animated: animated)
    }
}
