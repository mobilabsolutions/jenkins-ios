//
//  JobViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobViewController: UIViewController {

    var account: Account?
    var job: Job?
    
    //MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var descriptionWebView: UIWebView!
    
    //MARK: - Actions
    
    func build() {
        
        guard let job = job, let account = account
            else { return }
        
        try? NetworkManager.manager.performBuild(account: account, job: job, token: "", parameters: nil) { (data, error) in
            if error != nil{
                if let networkManagerError = error as? NetworkManagerError{
                    switch networkManagerError{
                        case NetworkManagerError.HTTPResponseNoSuccess(let code, _):
                            if code == 403{
                                //FIXME: This should show an alert indicating that the user should provide username + password
                                print("Error 403")
                            }
                        default:
                            return
                    }
                }
            }
        }
    }
    
    //MARK: - Viewcontroller lifecycl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        performRequest()
    }
    
    func like(){
        if job != nil{
            job!.isFavorite = !job!.isFavorite
            let imageName = !job!.isFavorite ? "HeartEmpty" : "HeartFull"
            (navigationItem.titleView as? UIImageView)?.image = UIImage(named: imageName)
        }
    }
    
    func performRequest(){
        if let account = account, let job = job{
            let userRequest = UserRequest(requestUrl: job.url, account: account)
            
            NetworkManager.manager.completeJobInformation(userRequest: userRequest, job: job, completion: { (job, error) in
                //FIXME: Actually present an error message here
                guard error == nil
                    else { print(error); return }
                DispatchQueue.main.async {
                    // FIXME: Update UI: Add other info for Job
                    if let description = job.description{
                        self.descriptionWebView.loadHTMLString(description, baseURL: nil)
                    }
                }
            })
            
            self.descriptionWebView.allowsLinkPreview = true
            self.descriptionWebView.delegate = self
            
            nameLabel.text = job.name
            urlLabel.text = "\(job.url)"
            //FIXME: Set image according to color
        }
    }
    
    //MARK: - ViewController Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BuildsTableViewController, segue.identifier == Constants.Identifiers.showBuildsSegue{
            dest.builds = job?.builds
            dest.account = account
        }
    }
    
    
}

extension JobViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return navigationType == .other
    }
}
