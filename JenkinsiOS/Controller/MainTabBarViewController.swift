//
//  MainTabBarViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 07.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, AccountProvidable {

    var account: Account? {
        didSet {
            if oldValue == nil && account != nil {
                updateSelectedAccountProvidable()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    private func sharedInit() {
        guard let viewControllers = viewControllers
            else { return }
        self.selectedIndex = min(viewControllers.count - 1, 2)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        viewControllers?.forEach({ (viewController) in
            if var accountProvidable = viewController as? AccountProvidable {
                accountProvidable.account = account
            }
        })
        
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    private func updateSelectedAccountProvidable() {
        if var accountProvidable = selectedViewController as? AccountProvidable {
            accountProvidable.account = account
        }
    }
    
    override var selectedViewController: UIViewController? {
        didSet {
            updateSelectedAccountProvidable()
        }
    }
    
    override var selectedIndex: Int {
        didSet {
            updateSelectedAccountProvidable()
        }
    }
}
