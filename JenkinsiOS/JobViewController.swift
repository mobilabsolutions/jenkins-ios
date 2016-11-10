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
        
        if account.password == nil || account.username == nil{
            var tokenTextField: UITextField!
            
            displayError(title: "Please Input a token", message: "To start a build without username or password, a token is required", textFieldConfigurations: [{ (textField) in
                textField.placeholder = "Token"
                tokenTextField = textField
                }], actions: [
                    UIAlertAction(title: "Use", style: .default, handler: { (_) in
                        self.performBuild(job: job, account: account, token: tokenTextField.text)
                    }),
                    UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                ])
        }
        else{
            performBuild(job: job, account: account, token: nil)
        }
    }
    
    private func performBuild(job: Job, account: Account, token: String?){
        
        let modalViewController = ModalInformationViewController(nibName: "ModalInformationViewController", bundle: Bundle.main)
        present(modalViewController, animated: true)
        modalViewController.withActivityIndicator(title: "Loading")
        
        try? NetworkManager.manager.performBuild(account: account, job: job, token: token, parameters: nil) { (data, error) in
            DispatchQueue.main.async {
                if let error = error{
                    modalViewController.dismiss(animated: true, completion: { 
                        self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!
                            
                            self.build()
                        })
                    })
                }
                else{
                    let successImageView = UIImageView(image: UIImage(named: "passedTestCase"))
                    successImageView.contentMode = .scaleAspectFit
                    modalViewController.with(title: "Success", detailView: successImageView)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(500), execute: {
                        modalViewController.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    //MARK: - Viewcontroller lifecycl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    func like(){
        if let account = account, job != nil{
            job?.toggleFavorite(account: account)
            let imageName = !job!.isFavorite ? "HeartEmpty" : "HeartFull"
            (navigationItem.titleView as? UIImageView)?.image = UIImage(named: imageName)
        }
    }
    
    func performRequest(){
        if let account = account, let job = job, job.isFullVersion == false{
            let userRequest = UserRequest(requestUrl: job.url, account: account)
            
            NetworkManager.manager.completeJobInformation(userRequest: userRequest, job: job, completion: { (job, error) in
                DispatchQueue.main.async {
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
                    
                    self.updateUI()
                }
            })
        }
    }
    
    private func setupUI(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Build", style: .plain, target: self, action: #selector(build))
        
        descriptionWebView.allowsLinkPreview = true
        descriptionWebView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(segueToNextViewController))
        showBuildsCell.addGestureRecognizer(tapRecognizer)
        
        updateUI()
    }
    
    func updateUI(){
        nameLabel.text = job?.name
        urlLabel.text = (job?.url).textify()
        
        let imageName = (job == nil || !job!.isFavorite) ? "HeartEmpty" : "HeartFull"
        
        if let titleView = navigationItem.titleView as? UIImageView{
            titleView.image = UIImage(named: imageName)
        }
        else{
            navigationItem.titleView = UIImageView(image: UIImage(named: imageName))
        }
        
        navigationItem.titleView?.sizeToFit()
        navigationItem.titleView?.isUserInteractionEnabled = true
        navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(like)))
        
        guard let job = job
            else { return }
        
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
