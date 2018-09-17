//
//  JobViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buildButton: BigButton!
    
    var account: Account?
    var job: Job?

    var viewWillAppearCalled = false
    private var showAllBuilds = false
    
    //MARK: - Actions

    @objc func triggerBuild() {
        guard let job = job
            else { return }

        if job.parameters.isEmpty{
            triggerBuildWithoutParameters()
        }
        else{
            prepareForBuildWithParameters()
        }
    }
    
    // MARK: - UITableViewDataSource and Delegate
    
    private enum JobSection: Int {
        case overview = 0
        case specialBuild = 1
        case otherBuilds = 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = JobSection(rawValue: indexPath.section)
            else { return UITableViewCell() }
        
        switch section {
        case .overview:
            return cellForOverView(indexPath: indexPath)
        case .specialBuild:
            return cellForSpecialBuild(indexPath: indexPath)
        case .otherBuilds:
            return cellForOtherBuilds(indexPath: indexPath)
        }
    }
    
    private func cellForOverView(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return cellForSimpleHeader(title: job?.name ?? "JOB", indexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.jobOverViewCell, for: indexPath) as! JobOverviewTableViewCell
        cell.job = job
        return cell
    }
    
    private func cellForSpecialBuild(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return cellForSimpleHeader(title: "LAST BUILD", indexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.specialBuildCell, for: indexPath) as! SpecialBuildTableViewCell
        cell.build = job?.lastBuild
        cell.delegate = self
        return cell
    }
    
    private func cellForOtherBuilds(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return cellForSelectableBuildsHeader(indexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.buildCell, for: indexPath) as! BuildTableViewCell
        
        if let builds = job?.builds, indexPath.row - 1 < builds.count {
            cell.build = builds[indexPath.row - 1]
        }
        
        return cell
    }
    
    private func cellForSimpleHeader(title: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.titleCell, for: indexPath)
        cell.textLabel?.text = title
        return cell
    }
    
    private func cellForSelectableBuildsHeader(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.buildsFilteringCell, for: indexPath) as! FilteringHeaderTableViewCell
        cell.delegate = self
        cell.title = "OTHER BUILDS"
        cell.canDeselectAllOptions = true
        cell.options = ["SHOW ALL (\(job?.builds.count ?? 0))"]
        cell.select(where: { _ in showAllBuilds })
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = job
            else { return 0 }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let job = job, let section = JobSection(rawValue: section)
            else { return 0 }
        
        switch section {
        case .overview:
            return 2
        case .specialBuild:
            return 2
        case .otherBuilds:
            return 1 + (showAllBuilds ? job.builds.count : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = JobSection(rawValue: indexPath.section)
            else { return }
        
        switch (section, indexPath.row) {
        case (.overview, _):
            return
        case (.specialBuild, 0):
            return
        case (.specialBuild, _):
            performSegue(withIdentifier: Constants.Identifiers.showBuildSegue, sender: self.job?.lastBuild)
        case (.otherBuilds, 0):
            return
        case (.otherBuilds, _):
            performSegue(withIdentifier: Constants.Identifiers.showBuildSegue, sender: self.job?.builds[indexPath.row - 1])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = JobSection(rawValue: indexPath.section)
            else { return 0 }
        
        switch section {
        case .overview:
            return indexPath.row == 0 ? 36 : 180
        case .specialBuild:
            return indexPath.row == 0 ? 36 : 129
        case .otherBuilds:
            return indexPath.row == 0 ? 67 : 74
        }
    }

    // MARK: - Building

    private func prepareForBuildWithParameters(){
        performSegue(withIdentifier: Constants.Identifiers.showParametersSegue, sender: nil)
    }

    private func triggerBuildWithoutParameters(){
        // TODO: This is somewhat hacky. Is there a nicer solution?
        let alert = UIAlertController(title: "Start Build", message: "Do you want to trigger a build?\n\n\n\n\n\n", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { [weak self] (_) in
            self?.buildWithoutParameters()
        }))
        
        let imageView = UIImageView(image: UIImage(named: "ic-rocket"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: -100).isActive = true
        imageView.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        present(alert, animated: true, completion: nil)
    }
    
    private func buildWithoutParameters() {
        guard let job = job, let account = account
            else { return }
        
        if account.password == nil || account.username == nil{
            self.displayInputTokenError(for: job, with: account)
        }
        else {
            let modalViewController = presentModalInformationViewController()
            performBuild(job: job, account: account, token: nil, parameters: nil){ result, error in
                DispatchQueue.main.async { [unowned self] in
                    self.completionForBuild()(modalViewController, result, error)
                }
            }
        }
    }
    
    private func displayInputTokenError(for job: Job, with account: Account){
        var tokenTextField: UITextField!
        
        let useAction = UIAlertAction(title: "Use", style: .default, handler: { [weak self] (_) in
            self?.performBuild(job: job, account: account, token: tokenTextField.text, parameters: nil){
                self?.completionForBuild()(self?.createModalInformationViewController(), $0, $1)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        displayError(title: "Please Input a token",
                     message: "To start a build without username or password, a token is required",
                     textFieldConfigurations: [{ (textField) in
                            textField.placeholder = "Token"
                            tokenTextField = textField
                        }], actions: [useAction, cancelAction])

    }
    
    private func presentModalInformationViewController() -> ModalInformationViewController? {
        guard let modal = createModalInformationViewController()
            else { return nil }
        present(modal, animated: true, completion: nil)
        return modal
    }

    private func createModalInformationViewController() -> ModalInformationViewController? {
        guard self.isViewLoaded && view.window != nil
            else { return nil }
        let modalViewController = ModalInformationViewController.withLoadingIndicator(title: "Loading...")
        modalViewController.dismissOnTap = false
        
        return modalViewController
    }

    private func completionForBuild() -> (ModalInformationViewController?, AnyObject?, Error?) ->(){
        return {

            modalViewController, data, error in

            if let error = error{
                if self.presentedViewController == modalViewController{
                    modalViewController?.dismiss(animated: true, completion: {
                        self.displayError(error: error)
                    })
                }
                else{
                    self.displayError(error: error)
                }
            }
            else{
                if self.presentedViewController == modalViewController{
                    modalViewController?.dismiss(animated: true, completion: nil)
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
        do {
            try NetworkManager.manager.performBuild(account: account, job: job, token: token, parameters: parameters, completion: completion)
            LoggingManager.loggingManager.logTriggeredBuild(withParameters: parameters != nil && !parameters!.isEmpty)
        }
        catch let error{
            completion(nil, error)
        }
    }

    //MARK: - Refreshing

    func updateData(completion: @escaping (Error?) -> ()){
        if let account = account, let job = job {
            let userRequest = UserRequest.userRequestForJob(account: account, requestUrl: job.url)
            _ = NetworkManager.manager.completeJobInformation(userRequest: userRequest, job: job, completion: { (_, error) in
                completion(error)
            })
        }
    }

    //MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let filteringHeaderViewNib = UINib(nibName: "FilteringHeaderTableViewCell", bundle: .main)
        self.tableView.register(filteringHeaderViewNib, forCellReuseIdentifier: Constants.Identifiers.buildsFilteringCell)
        
        self.tableView.backgroundColor = Constants.UI.backgroundColor
        self.view.backgroundColor = Constants.UI.backgroundColor
        self.tableView.separatorStyle = .none
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.view.frame.height - self.buildButton.frame.minY, right: 0)
        
        self.buildButton.addTarget(self, action: #selector(triggerBuild), for: .touchUpInside)
        
        performRequest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        viewWillAppearCalled = true
    }

    @objc func openUrl(){
        guard let job = self.job
              else { return }
        UIApplication.shared.openURL(job.url)
    }

    @objc func favorite(){
        if let account = account, job != nil{
            job?.toggleFavorite(account: account)
            let imageName = !job!.isFavorite ? "fav" : "fav-fill"
            navigationItem.rightBarButtonItem?.image = UIImage(named: imageName)
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
                
                LoggingManager.loggingManager.log(contentView: .job)

                if self.viewWillAppearCalled {
                    self.updateUI()
                }
            }
        }
    }

    private func setupUI() {
        let imageName = (job == nil || !job!.isFavorite) ? "fav" : "fav-fill"
        let favoriteBarButtonItem = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: self, action: #selector(favorite))
        navigationItem.rightBarButtonItem = favoriteBarButtonItem
        
        self.title = "Jobs"
        
        updateUI()
    }
    
    
    func updateUI() {
        self.tableView.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = job?.isFullVersion ?? false
        self.buildButton.isEnabled = job?.isFullVersion ?? false
    }

    //MARK: - ViewController Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ParametersTableViewController, segue.identifier == Constants.Identifiers.showParametersSegue {
            dest.parameters = job?.parameters ?? []
            dest.delegate = self
        }
        else if let dest = segue.destination as? BuildViewController, segue.identifier == Constants.Identifiers.showBuildSegue, let build = sender as? Build {
            dest.account = account
            dest.build = build
        }
        else if let dest = segue.destination as? ArtifactsTableViewController, segue.identifier == Constants.Identifiers.showArtifactsSegue,
            let build = sender as? Build {
            dest.account = account
            dest.build = build
        }
        else if let dest = segue.destination as? TestResultsTableViewController, segue.identifier == Constants.Identifiers.showTestResultsSegue,
            let build = sender as? Build {
            dest.account = account
            dest.build = build
        }
        else if let dest = segue.destination as? ConsoleOutputViewController, segue.identifier == Constants.Identifiers.showConsoleOutputSegue,
            let build = sender as? Build, let account = self.account {
            dest.request = NetworkManager.manager.getConsoleOutputUserRequest(build: build, account: account)
        }
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

extension JobViewController: BuildsInformationOpeningDelegate {
    func showLogs(build: Build) {
        performSegue(withIdentifier: Constants.Identifiers.showConsoleOutputSegue, sender: build)
    }
    
    func showArtifacts(build: Build) {
        performSegue(withIdentifier: Constants.Identifiers.showArtifactsSegue, sender: build)
    }
    
    func showTestResults(build: Build) {
        performSegue(withIdentifier: Constants.Identifiers.showTestResultsSegue, sender: build)
    }
}

extension JobViewController: FilteringHeaderTableViewCellDelegate {
    func didSelect(selected: CustomStringConvertible, cell: FilteringHeaderTableViewCell) {
        if !showAllBuilds {
            self.showAllBuilds = true
            self.tableView.reloadSections([JobSection.otherBuilds.rawValue], with: .automatic)
        }
    }
    
    func didDeselectAll() {
        if showAllBuilds {
            self.showAllBuilds = false
            self.tableView.reloadSections([JobSection.otherBuilds.rawValue], with: .automatic)
        }
    }
}
