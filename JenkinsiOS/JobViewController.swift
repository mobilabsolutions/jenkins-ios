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
    @IBOutlet weak var healthReportLabel: UILabel!
    @IBOutlet weak var showBuildsCell: UITableViewCell!
    
    //MARK: - Actions
    
    func build() {
        guard let job = job, let account = account
            else { return }
        
        try? NetworkManager.manager.performBuild(account: account, job: job, token: "", parameters: nil) { (data, error) in
            if let error = error{
                self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                    self.account?.username = returnData["username"]!
                    self.account?.password = returnData["password"]!
                    
                    self.build()
                })
            }
            print(data)
        }
    }
    
    //MARK: - Viewcontroller lifecycl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        performRequest()
    }
    
    func like(){
        if let account = account, job != nil{
            job?.toggleFavorite(account: account)
            let imageName = !job!.isFavorite ? "HeartEmpty" : "HeartFull"
            (navigationItem.titleView as? UIImageView)?.image = UIImage(named: imageName)
        }
    }
    
    func performRequest(){
        if let account = account, let job = job{
            let userRequest = UserRequest(requestUrl: job.url, account: account)
            
            NetworkManager.manager.completeJobInformation(userRequest: userRequest, job: job, completion: { (job, error) in
                guard error == nil
                    else {
                        if let error = error{
                            self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                                self.account?.username = returnData["username"]!
                                self.account?.password = returnData["password"]!
                                
                                self.performRequest()
                            })
                        }
                        return
                }
                
                DispatchQueue.main.async {
                    let description = (job.description == nil || job.description!.isEmpty) ? "No description" : job.description!
                    self.descriptionWebView.loadHTMLString("<span style=\"font-family: san francisco, helvetica\">" + description + "</span>", baseURL: nil)
                    self.descriptionWebView.sizeToFit()
                    
                    if job.healthReport.count > 0{
                        self.healthReportLabel.text = job.healthReport.map{ $0.description }.joined(separator: "\n")
                    }
                    else {
                        self.healthReportLabel.text = "No health report"
                    }
                    
                    if let icon = job.healthReport.first?.iconClassName{
                        self.colorImageView.image = UIImage(named: icon)
                    }
                }
            })
        }
    }
    
    func setupUI(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Build", style: .plain, target: self, action: #selector(build))
        
        descriptionWebView.allowsLinkPreview = true
        descriptionWebView.delegate = self
    
        nameLabel.text = job?.name
        urlLabel.text = (job?.url).textify()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(segueToNextViewController))
        showBuildsCell.addGestureRecognizer(tapRecognizer)
        
        let imageName = (job == nil || !job!.isFavorite) ? "HeartEmpty" : "HeartFull"
        navigationItem.titleView = UIImageView(image: UIImage(named: imageName))
        
        navigationItem.titleView?.sizeToFit()
        navigationItem.titleView?.isUserInteractionEnabled = true
        navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(like)))
        
    }
    
    //MARK: - ViewController Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BuildsTableViewController, segue.identifier == Constants.Identifiers.showBuildsSegue{
            dest.builds = job?.builds
            dest.specialBuilds = job?.specialBuilds.filter{ $0.1 != nil }.map{ ($0.0, $0.1!) } ?? []
            dest.account = account
        }
    }
    
    
    @objc private func segueToNextViewController(){
        performSegue(withIdentifier: Constants.Identifiers.showBuildsSegue, sender: nil)
    }
    
}

extension JobViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if navigationType != .other, let url = request.url{
            UIApplication.shared.openURL(url)
        }
        
        return navigationType == .other
    }
}
