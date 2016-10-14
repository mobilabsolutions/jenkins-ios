//
//  BuildViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildViewController: UITableViewController {

    //MARK: - Instance variables
    
    var build: Build?
    var account: Account?
    
    class DisplayData{
        var segueIdentifier: String?
        var key: String
        var value: String
        var cellIdentifier: String
        var viewControllerIdentifier: String?
        
        init(key: String, value: String, cellIdentifier: String, segueIdentifier: String? = nil, viewControllerIdentifier: String? = nil){
            self.key = key
            self.value = value
            self.cellIdentifier = cellIdentifier
            self.segueIdentifier = segueIdentifier
            self.viewControllerIdentifier = viewControllerIdentifier
        }
    }
    
    var displayData: [DisplayData] = []
    
    private var favoriteImage: UIImage?{
        get{
            return (build != nil && build!.isFavorite) ? UIImage(named: "HeartFull") : UIImage(named: "HeartEmpty")
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpUI()
        updateData()
        performRequests()
        registerForPreviewing(with: self, sourceView: tableView)
    }

    
    //MARK: - Actions
    
    @objc private func toggleLike(){
        guard let account = account
            else { return }
        build?.toggleFavorite(account: account)
        (navigationItem.titleView as? UIImageView)?.image = favoriteImage
    }
    
    //MARK: - Data loading and displaying
    
    private func performRequests(){
        guard let build = build
            else { return }
        
        if build.isFullVersion == false, let account = account{
            let userRequest = UserRequest(requestUrl: build.url, account: account)
            
            NetworkManager.manager.completeBuildInformation(userRequest: userRequest, build: build, completion: { (_, error) in
                DispatchQueue.main.async {
                    
                    if let error = error{
                        self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!
                            
                            self.performRequests()
                        })
                    }
                    
                    self.updateData()
                }
            })
        }
    }
    
    private func setUpUI(){        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleLike))
        navigationItem.titleView = UIImageView(image: favoriteImage)
        navigationItem.titleView?.isUserInteractionEnabled = true
        navigationItem.titleView?.addGestureRecognizer(recognizer)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    private func updateData(){
        
        displayData = [
            DisplayData(key: "Number", value: "\((build?.number).textify())", cellIdentifier: Constants.Identifiers.staticBuildInfoCell, segueIdentifier: nil),
            DisplayData(key: "Cause", value:
                (build?.actions?.causes.reduce("",
                                               { (str, cause) -> String in
                                                    return str + cause.shortDescription
                                                }
                    )).textify(), cellIdentifier: Constants.Identifiers.longBuildInfoCell, segueIdentifier: nil),
            
            DisplayData(key: "Result", value: build?.result ?? "Loading result...", cellIdentifier: Constants.Identifiers.staticBuildInfoCell),
            DisplayData(key: "ID", value: build?.id ?? "Loading ID...", cellIdentifier: Constants.Identifiers.staticBuildInfoCell),
            DisplayData(key: "Duration", value: build?.duration?.toString() ?? "Loading time interval...", cellIdentifier: Constants.Identifiers.staticBuildInfoCell),
            DisplayData(key: "Estimated", value: build?.estimatedDuration?.toString() ?? "Loading time interval...", cellIdentifier: Constants.Identifiers.staticBuildInfoCell),
            DisplayData(key: "Building", value: build?.building != nil ? "\(build!.building!)" : "Unknown", cellIdentifier: Constants.Identifiers.staticBuildInfoCell),
            DisplayData(key: "Built On", value: build?.builtOn ?? "Unknown", cellIdentifier: Constants.Identifiers.staticBuildInfoCell),
            DisplayData(key: "Changes (\(build?.changeSets.reduce(0){$0 + $1.items.count} ?? 0))", value: "", cellIdentifier: Constants.Identifiers.moreInfoBuildCell, segueIdentifier: Constants.Identifiers.showChangesSegue, viewControllerIdentifier: "ChangesViewController"),
            DisplayData(key: "Test Results", value: "", cellIdentifier: Constants.Identifiers.moreInfoBuildCell, segueIdentifier: Constants.Identifiers.showTestResultsSegue, viewControllerIdentifier: "TestResultsViewController"),
            DisplayData(key: "Console Output", value: "", cellIdentifier: Constants.Identifiers.moreInfoBuildCell, segueIdentifier: Constants.Identifiers.showConsoleOutputSegue, viewControllerIdentifier: "ConsoleOutputViewController")
        ]
        
        nameLabel.text = build?.fullDisplayName ?? build?.displayName ?? "Build #\((build?.number).textify())"
        
        tableView.reloadData()
    }
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = sender as? UIViewController{
           prepare(viewController: dest)
        }
    }
    
    fileprivate func prepare(viewController: UIViewController){
        if let consoleOutputViewController = viewController as? ConsoleOutputViewController{
            consoleOutputViewController.url = build?.consoleOutputUrl
        }
        else if let changesTableViewController = viewController as? ChangesTableViewController{
            changesTableViewController.changeSetItems = []
            
            var commitIds: [String] = []
            
            build?.changeSets.forEach({ (changeSet) in
                for change in changeSet.items{
                    if let commitId = change.commitId, !commitIds.contains(commitId){
                        changesTableViewController.changeSetItems?.append(change)
                        commitIds.append(commitId)
                    }
                }
            })
        }
        else if let testResultsViewController = viewController as? TestResultsTableViewController{
            testResultsViewController.build = build
            testResultsViewController.account = account
        }
    }
    
    //MARK: - Table view datasource and delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: displayData[indexPath.row].cellIdentifier, for: indexPath)
        
        if displayData[indexPath.row].cellIdentifier == Constants.Identifiers.staticBuildInfoCell{
            cell.textLabel?.text = displayData[indexPath.row].key
            cell.detailTextLabel?.text = displayData[indexPath.row].value
        }
        else if displayData[indexPath.row].cellIdentifier == Constants.Identifiers.moreInfoBuildCell{
            cell.textLabel?.text = displayData[indexPath.row].key
        }
        else if displayData[indexPath.row].cellIdentifier == Constants.Identifiers.longBuildInfoCell, let longBuildInfoCell = cell as? LongBuildInfoTableViewCell{
            longBuildInfoCell.titleLabel.text = displayData[indexPath.row].key
            longBuildInfoCell.infoLabel.text = displayData[indexPath.row].value
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let segueIdentifier = displayData[indexPath.row].segueIdentifier{
            performSegue(withIdentifier: segueIdentifier, sender: displayData[indexPath.row])
        }
    }
}

extension BuildViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let identifier = displayData[indexPath.row].viewControllerIdentifier
            else { return nil }
        guard let viewController = (UIApplication.shared.delegate as? AppDelegate)?.getViewController(name: identifier)
            else { return nil }
        
        prepare(viewController: viewController)
        
        return viewController
    }
}
