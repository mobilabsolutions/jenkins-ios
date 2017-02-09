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
    @IBOutlet weak var showBuildsCell: UIView!

    var viewWillAppearCalled = false
    var buildProvidable: BuildProvidable? = nil
    
    //MARK: - Actions

    func triggerBuild() {
        guard let job = job
            else { return }

        if job.parameters.isEmpty{
            buildWithoutParameters()
        }
        else{
            prepareForBuildWithParameters()
        }
    }

    private func prepareForBuildWithParameters(){
        performSegue(withIdentifier: Constants.Identifiers.showParametersSegue, sender: nil)
    }

    private func buildWithoutParameters(){
        guard let job = job, let account = account
            else { return }

        let modalViewController = presentModalInformationViewController()

        if account.password == nil || account.username == nil{
            modalViewController?.dismiss(animated: true, completion: { 
                self.displayInputTokenError(for: job, with: account, modalViewController: modalViewController)
            })
        }
        else{
            performBuild(job: job, account: account, token: nil, parameters: nil){
                self.completionForBuild()(modalViewController, $0, $1)
            }
        }
    }
    
    private func displayInputTokenError(for job: Job, with account: Account, modalViewController: ModalInformationViewController?){
        var tokenTextField: UITextField!
        displayError(title: "Please Input a token",
                     message: "To start a build without username or password, a token is required",
                     textFieldConfigurations: [{ (textField) in
            textField.placeholder = "Token"
            tokenTextField = textField
            }],
                     actions: [
                UIAlertAction(title: "Use", style: .default, handler: { (_) in
                    self.performBuild(job: job, account: account, token: tokenTextField.text, parameters: nil){
                        self.completionForBuild()(modalViewController, $0, $1)
                    }
                }),
                UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ])

    }
    
    private func presentModalInformationViewController() -> ModalInformationViewController?{
        if self.isViewLoaded && view.window != nil{
            let modalViewController = ModalInformationViewController.withLoadingIndicator(title: "Loading...")
            present(modalViewController, animated: true)
            
            modalViewController.dismissOnTap = false
            
            return modalViewController
        }
        return nil
    }

    private func completionForBuild() -> (ModalInformationViewController?, AnyObject?, Error?) ->(){
        return {

            modalViewController, data, error in

            if let error = error{
                
                if modalViewController?.isBeingPresented == true{
                    modalViewController?.dismiss(animated: true, completion: {
                        self.displayError(error: error)
                    })
                }
                else{
                    self.displayError(error: error)
                }
            }
        }
    }

    private func displayError(error: Error){
        self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
            self.account?.username = returnData["username"]!
            self.account?.password = returnData["password"]!
            
            self.triggerBuild()
        })
    }
    
    private func performBuild(job: Job, account: Account, token: String?){

        let modalViewController = ModalInformationViewController.withLoadingIndicator(title: "Loading...")
        present(modalViewController, animated: true)

        try? NetworkManager.manager.performBuild(account: account, job: job, token: token, parameters: nil) { (data, error) in
            DispatchQueue.main.async {
                if let error = error{
                    modalViewController.dismiss(animated: true, completion: {
                        self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!

                            self.performBuild(job: job, account: account, token: token)
                        })
                    })
                }
                else{
                    let successImageView = UIImageView(image: UIImage(named: "passedTestCase"))
                    successImageView.contentMode = .scaleAspectFit
                    modalViewController.set(title: "Success", detailView: successImageView)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(500), execute: {
                        modalViewController.dismiss(animated: true, completion: nil)
                    })
                }
            }

        }
    }

    fileprivate func performBuild(job: Job, account: Account, token: String?, parameters: [ParameterValue]?, completion: @escaping (AnyObject?, Error?) -> ()){
        try? NetworkManager.manager.performBuild(account: account, job: job, token: token, parameters: parameters, completion: completion)
    }

    //MARK: - Refreshing

    func updateData(completion: @escaping (Error?) -> ()){
        if let account = account, let job = job{
            let userRequest = UserRequest(requestUrl: job.url, account: account)

            _ = NetworkManager.manager.completeJobInformation(userRequest: userRequest, job: job, completion: { (_, error) in
                completion(error)
            })
        }
    }

    //MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        performRequest()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(openUrl))
        urlLabel.addGestureRecognizer(tapRecognizer)
        urlLabel.isUserInteractionEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        viewWillAppearCalled = true
    }

    func openUrl(){
        guard let job = self.job
              else { return }
        UIApplication.shared.openURL(job.url)
    }

    func like(){
        if let account = account, job != nil{
            job?.toggleFavorite(account: account)
            let imageName = !job!.isFavorite ? "HeartEmpty" : "HeartFull"
            (navigationItem.titleView as? UIImageView)?.image = UIImage(named: imageName)
        }
    }

    func performRequest(){
        updateData { (error) in
            DispatchQueue.main.async {
                guard error == nil
                    else {
                        if let error = error{
                            self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                                self.updateAccount(data: returnData)
                                self.performRequest()
                            })
                        }
                        return
                }
                
                self.buildProvidable?.setBuilds(builds: self.job?.builds ?? [], specialBuilds: self.specialBuilds() ?? [])
                self.buildProvidable?.buildsAlreadyLoaded = true

                LoggingManager.loggingManager.log(contentView: .job)

                if self.viewWillAppearCalled{
                    self.updateUI()
                }
            }
        }
    }

    private func setupUI(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Build", style: .plain, target: self, action: #selector(triggerBuild))
        navigationItem.rightBarButtonItem?.isEnabled = false

        descriptionWebView.allowsLinkPreview = true
        descriptionWebView.delegate = self

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(segueToNextViewController))
        showBuildsCell.addGestureRecognizer(tapRecognizer)

        updateUI()
        
        guard job?.healthReport.first == nil
            else { stopIndicator(); return }
        addLoadingIndicator()
    }
    
    private func addLoadingIndicator(){
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        colorImageView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: colorImageView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: colorImageView.centerYAnchor).isActive = true
        
        indicator.startAnimating()
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
        self.descriptionWebView.loadHTMLString("<span style=\"font-family:'Source Sans Pro', helvetica\">" + description + "</span>", baseURL: nil)
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
        else if job.isFullVersion{
            self.colorImageView.image = UIImage(named: "Jenkins_Loader")
        }
        
        if job.healthReport.first != nil || job.isFullVersion == true{
            stopIndicator()
        }

        navigationItem.rightBarButtonItem?.isEnabled = job.isFullVersion
    }

    private func stopIndicator(){
        if let indicator = colorImageView.subviews.first as? UIActivityIndicatorView{
            indicator.stopAnimating()
        }
    }
    
    //MARK: - ViewController Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BuildsTableViewController, segue.identifier == Constants.Identifiers.showBuildsSegue{
            dest.account = account
            dest.buildsAlreadyLoaded = (job?.isFullVersion != nil && job!.isFullVersion)
            dest.setBuilds(builds: job?.builds ?? [], specialBuilds: specialBuilds() ?? [])
            dest.dataSource = self
            self.buildProvidable = dest
        }
        else if let dest = segue.destination as? ParametersTableViewController, segue.identifier == Constants.Identifiers.showParametersSegue{
            dest.parameters = job?.parameters ?? []
            dest.delegate = self
        }
    }


    @objc private func segueToNextViewController(){
        performSegue(withIdentifier: Constants.Identifiers.showBuildsSegue, sender: nil)
    }

    //MARK: - Helpers
    fileprivate func specialBuilds() -> [(String, Build)]?{
        return job?.specialBuilds.filter{ $0.1 != nil }.map{ ($0.0, $0.1!) }
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

extension JobViewController: ParametersViewControllerDelegate{
    func build(parameters: [ParameterValue], completion: @escaping (Error?) -> ()) {

        guard let job = job, let account = account
            else { completion(BuildError.notEnoughDataError); return }


        performBuild(job: job, account: account, token: nil, parameters: parameters){
            _, error in
            completion(error)
        }
    }

    func updateAccount(data: [String : String?]) {
        self.account?.username = data["username"]!
        self.account?.password = data["password"]!
    }
}

extension JobViewController: BuildsTableViewControllerDataSource{
    func loadBuilds(completion: @escaping ([Build]?, [(String, Build)]?) -> ()){
        updateData { (error) in
            DispatchQueue.main.async {
                guard error == nil
                    else { completion(nil, nil); return }
                completion(self.job?.builds, self.specialBuilds())
            }
        }
    }
}
