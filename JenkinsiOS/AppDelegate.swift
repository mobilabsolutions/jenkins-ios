//
//  AppDelegate.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        ApplicationUserManager.manager.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ApplicationUserManager.manager.save()
    }


}

