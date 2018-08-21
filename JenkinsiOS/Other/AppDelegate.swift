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
        ApplicationUserManager.manager.applicationUser.timesOpenedApp += 1
        saveIndefinitely()
        
        let appearanceManager = AppearanceManager()
        appearanceManager.setGlobalAppearance()
        
        setCurrentAccountForRootViewController()
        handleReviewReminder()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication){
        (window?.rootViewController as? UINavigationController)?.setNavigationBarHidden(false, animated: true)
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
            nav.popToRootViewController(animated: false)
            nav.pushViewController(getViewController(name: "FavoritesViewController"), animated: false)
            nav.pushViewController(viewController(for: type, with: favorite), animated: false)
        }
        
        return true
    }
    
    private func setCurrentAccountForRootViewController() {
        if var accountProvidable = window?.rootViewController as? AccountProvidable {
            accountProvidable.account = AccountManager.manager.currentAccount
        }
    }
    
    private func viewController(for favoriteType: Favorite.FavoriteType, with favorite: Favorite) -> UIViewController{
        switch favoriteType{
            case .job:
                let vc = getViewController(name: "JobViewController") as! JobViewController
                vc.account = favorite.account
                
                guard let account = favorite.account
                    else { return vc }
                
                let userRequest = UserRequest.userRequestForJob(account: account, requestUrl: favorite.url)
                _ = NetworkManager.manager.getJob(userRequest: userRequest, completion: { (job, _) in
                    vc.job = job
                    
                    DispatchQueue.main.async {
                        if vc.viewWillAppearCalled {
                            vc.updateUI()
                        }
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
                        if vc.viewWillAppearCalled{
                            vc.updateData()
                        }
                    }
                })
                
                return vc
        case .folder:
            let vc = getViewController(name: "JobsTableViewController") as! JobsTableViewController
            vc.account = favorite.account
            guard let account = favorite.account
                else { return vc }
        
            vc.userRequest = UserRequest.userRequestForJobList(account: account, requestUrl: favorite.url)
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
    
    private func handleReviewReminder(){
        
        guard let navViewController = window?.rootViewController as? UINavigationController,
            let topController = navViewController.topViewController
            else { return }
    
        let reviewHandler = ReviewHandler(presentOn: topController)
        
        if(reviewHandler.mayAskForReview()){
            reviewHandler.askForReview()
        }
    }
    
    //MARK: - Helpers
    func getViewController(name: String) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
}

