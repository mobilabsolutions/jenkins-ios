//
//  AppDelegate.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        ApplicationUserManager.manager.save()
        AccountManager.manager.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ApplicationUserManager.manager.save()
        AccountManager.manager.save()
    }

    func applicationDidFinishLaunching(_ application: UIApplication) {
        Fabric.with([Crashlytics.self])
        saveIndefinitely()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { return false }
        
        guard components.host == "present", let queryItems = components.queryItems
            else { return false }
        
        guard let urlString = queryItems.filter({ $0.name == "url" }).first?.value,
              let url =  URL(string: urlString),
              let typeString = queryItems.filter({ $0.name == "type" }).first?.value,
              let type = Favorite.FavoriteType(rawValue: typeString)
        else { return false }
        
        guard let favorite = ApplicationUserManager.manager.applicationUser.favorites.first(where: { $0.url == url && $0.type == type })
            else { return false }
        
        if let nav = window?.rootViewController as? UINavigationController{
            nav.pushViewController(getViewController(name: "FavoritesViewController"), animated: true)
            nav.pushViewController(viewController(for: type, with: favorite), animated: true)
        }
        
        return true
    }
    
    private func viewController(for favoriteType: Favorite.FavoriteType, with favorite: Favorite) -> UIViewController{
        switch favoriteType{
            case .job:
                let vc = getViewController(name: "JobViewController") as! JobViewController
                vc.account = favorite.account
                
                guard let account = favorite.account
                    else { return vc }
                
                let userRequest = UserRequest(requestUrl: favorite.url, account: account)
                _ = NetworkManager.manager.getJob(userRequest: userRequest, completion: { (job, _) in
                    vc.job = job
                    
                    DispatchQueue.main.async {
                        vc.updateUI()
                    }
                    
                })
                return vc
            case .build:
                let vc = getViewController(name: "BuildViewController") as! BuildViewController
                vc.account = favorite.account
                
                guard let account = favorite.account
                    else { return vc }
                
                let userRequest = UserRequest(requestUrl: favorite.url, account: account)
                _ = NetworkManager.manager.getBuild(userRequest: userRequest, completion: { (build, _) in
                    vc.build = build
                    DispatchQueue.main.async {
                        vc.updateData()
                    }
                })
                
                return vc
        }
    }
    
    private func saveOnce(){
        ApplicationUserManager.manager.save()
        AccountManager.manager.save()
    }
    
    private func saveIndefinitely(){
        saveOnce()
        let deadline = DispatchTime.now() + .seconds(30)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.saveIndefinitely()
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == Constants.Identifiers.favoritesShortcutItemType{
            let favoritesViewController = getViewController(name: "FavoritesViewController")
            if let nav = window?.rootViewController as? UINavigationController{
                nav.pushViewController(favoritesViewController, animated: true)
            }
        }
    }
    
    //MARK: - Helpers
    func getViewController(name: String) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
}

