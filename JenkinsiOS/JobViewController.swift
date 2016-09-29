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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Build", style: .plain, target: self, action: #selector(build))
        
        if let account = account, let job = job{
            let userRequest = UserRequest(requestUrl: job.url, account: account)
            
            NetworkManager.manager.completeJobInformation(userRequest: userRequest, job: job, completion: { (job, error) in
                //FIXME: Actually present an error message here
                guard error == nil
                    else { print(error); return }
                DispatchQueue.main.async {
                    // FIXME: Update UI
                    if let description = job.description{
                        self.descriptionWebView.loadHTMLString(description, baseURL: nil)
                    }
                }
            })
            
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
