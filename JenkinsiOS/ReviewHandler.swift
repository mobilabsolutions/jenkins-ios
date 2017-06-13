//
//  ReviewHandler.swift
//  JenkinsiOS
//
//  Created by Robert on 01.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class ReviewHandler: NSObject{
    
    weak var viewController: UIViewController?
    
    let user = ApplicationUserManager.manager.applicationUser
    
    init(presentOn viewController: UIViewController){
        self.viewController = viewController
    }
    
    func askForReview(){
        if #available(iOS 10.3, *){
            SKStoreReviewController.requestReview()
        }
        else {
            guard let viewController = self.viewController, viewController.isViewLoaded
                    else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(10), execute: askForReview)
                return
            }

            let reviewViewController = ReviewReminderViewController()
            reviewViewController.delegate = self
            viewController.present(reviewViewController, animated: true, completion: nil)
        }
    }
    
    func mayAskForReview() -> Bool{
        return true
        //return !user.canceledReviewReminder && (user.timesOpenedApp >= 7)
    }
    
    func triggerReview(){
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(getAppStoreURL(), options: [:]){
                success in
                self.user.canceledReviewReminder = success
                ApplicationUserManager.manager.save()
            }
        }
        else {
            // Fallback on earlier versions
            let success = UIApplication.shared.openURL(getAppStoreURL())
            self.user.canceledReviewReminder = success
            ApplicationUserManager.manager.save()
        }
    }
    
    func postponeReviewReminder(){
        user.timesOpenedApp = 0
        ApplicationUserManager.manager.save()
    }
    
    func endReviewReminder(){
        user.canceledReviewReminder = true
        ApplicationUserManager.manager.save()
    }
    
    private func getAppStoreURL() -> URL{
        var parameter = ""
        if #available(iOS 10.3, *) {
            parameter = "?action=write-review"
        }
        return URL(string: "itms-apps://itunes.apple.com/app/id" + getAppStoreID() + parameter)!
    }
    
    private func getAppStoreID() -> String{
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url)
            else { return "" }
        
        return dict.object(forKey: "App Store ID") as? String ?? ""
    }
    
    func openMailComposer(with feedback: String){
        let mailComposer = MFMailComposeViewController()
        mailComposer.setMessageBody(feedback, isHTML: false)
        mailComposer.setSubject("JenkinsiOS Feedback")
        mailComposer.setToRecipients(["jenkinsios@mobilabsolutions.com"])
        mailComposer.mailComposeDelegate = self
        viewController?.present(mailComposer, animated: true, completion: nil)
    }
}

extension ReviewHandler: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        user.canceledReviewReminder = true
        ApplicationUserManager.manager.save()
        viewController?.dismiss(animated: true, completion: nil)
    }
}

extension ReviewHandler: ReviewReminderViewControllerDelegate{
    func review() {
        triggerReview()
    }
    
    func stopReminding() {
        endReviewReminder()
    }
    
    func feedback(feedback: String) {
        openMailComposer(with: feedback)
    }
    
    func minimumNumberOfStarsForReview() -> Int{
        return 4
    }
    
    func postponeReminder(){
        postponeReviewReminder()
    }
}
