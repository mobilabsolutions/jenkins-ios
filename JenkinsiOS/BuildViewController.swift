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
    
    var viewWillAppearCalled = false
    
    class DisplayData{
        var segueIdentifier: String?
        var key: String
        var value: String
        var cellIdentifier: String
        var viewControllerIdentifier: String?
        var enabled: Bool
        
        init(key: String, value: String, cellIdentifier: String, segueIdentifier: String? = nil, viewControllerIdentifier: String? = nil , enabled: Bool = true){
            self.key = key
            self.value = value
            self.cellIdentifier = cellIdentifier
            self.segueIdentifier = segueIdentifier
            self.viewControllerIdentifier = viewControllerIdentifier
            self.enabled = enabled
        }
    }
    
    var displayData: [DisplayData] = []
    
    private var favoriteImage: UIImage?{
        get{
            return (build != nil && build!.isFavorite) ? UIImage(named: "HeartFull") : UIImage(named: "HeartEmpty")
        }
    }
    
    private let dateFormatter = DateFormatter()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpUI()
        setupDateFormatter()
        updateData()
        performRequests()
        registerForPreviewing(with: self, sourceView: tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearCalled = true
        LoggingManager.loggingManager.log(contentView: .build)
    }
   
    //MARK: - Setup of objects
    private func setupDateFormatter(){
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.formattingContext = .standalone
        dateFormatter.locale = Locale.autoupdatingCurrent
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
            
            _ = NetworkManager.manager.completeBuildInformation(userRequest: userRequest, build: build, completion: { (_, error) in
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
    
    func updateData(){
        
        let changesCount = build?.changeSets.reduce(0){$0 + $1.items.count} ?? 0
        let artifactsCount = build?.artifacts.count ?? 0
        
        let moreInfoBuildCell = Constants.Identifiers.moreInfoBuildCell
        let staticBuildInfoCell = Constants.Identifiers.staticBuildInfoCell
        
        let testResultsVC = "TestResultsViewController"
        let changesVC = "ChangesViewController"
        let artifactsVC = "ArtifactsViewController"
        let consoleOutputVC = "ConsoleOutputViewController"
        
        let resultString: String!
        let idString: String!
        let timeIntervalString: String!
        let estimatedTimeIntervalString: String!
        let buildingString: String!
        let builtOnString: String!
        let timeStampString: String!
        
        if let build = build{
            resultString = build.result ?? "Unknown"
            idString = build.id ?? "Unknown"
            timeStampString = build.timeStamp != nil ? dateFormatter.string(from: build.timeStamp!) : "Unknown"
            timeIntervalString = build.duration?.toString() ?? "Unknown"
            estimatedTimeIntervalString = build.estimatedDuration?.toString() ?? "Unknown"
            buildingString = build.building != nil ? build.building!.humanReadableString : "Unknown"
            builtOnString = (build.builtOn ?? "Unknown") != "" ? (build.builtOn ?? "Unknown") : "Unknown"
        }
        else{
            resultString = "Loading result..."
            idString = "Loading ID..."
            timeIntervalString = "Loading time interval..."
            estimatedTimeIntervalString = "Loading time interval..."
            buildingString = "Loading information..."
            builtOnString = "Loading information..."
            timeStampString = "Loading information..."
        }
        
        var causes: [Cause] = []
        
        if let multipleCauses = build?.actions?.causes{
            for cause in multipleCauses{
                if !causes.contains{ $0.shortDescription == cause.shortDescription }{
                    causes.append(cause)
                }
            }
        }
        
        let causeText = causes.reduce("", { (str, cause) -> String in
                                                        return str + cause.shortDescription + "\n"
        })
        
        displayData = [
            DisplayData(key: "Number", value: "\((build?.number).textify())", cellIdentifier: Constants.Identifiers.staticBuildInfoCell, segueIdentifier: nil),
            DisplayData(key: "Cause", value: causeText, cellIdentifier: Constants.Identifiers.longBuildInfoCell, segueIdentifier: nil),
            DisplayData(key: "Result", value: resultString, cellIdentifier: staticBuildInfoCell),
            DisplayData(key: "ID", value: idString, cellIdentifier: staticBuildInfoCell),
            DisplayData(key: "Started", value: timeStampString, cellIdentifier: staticBuildInfoCell),
            DisplayData(key: "Duration", value: timeIntervalString, cellIdentifier: staticBuildInfoCell),
            DisplayData(key: "Estimated", value: estimatedTimeIntervalString, cellIdentifier: staticBuildInfoCell),
            DisplayData(key: "Building", value: buildingString, cellIdentifier: staticBuildInfoCell),
            DisplayData(key: "Built On", value: builtOnString, cellIdentifier: staticBuildInfoCell),
            
            DisplayData(key: "Changes (\(changesCount))", value: "", cellIdentifier: moreInfoBuildCell, segueIdentifier: Constants.Identifiers.showChangesSegue, viewControllerIdentifier: changesVC, enabled: changesCount > 0),
            
            DisplayData(key: "Test Results", value: "", cellIdentifier: moreInfoBuildCell, segueIdentifier: Constants.Identifiers.showTestResultsSegue, viewControllerIdentifier: testResultsVC),
            
            DisplayData(key: "Artifacts (\(artifactsCount))", value: "", cellIdentifier: moreInfoBuildCell, segueIdentifier: Constants.Identifiers.showArtifactsSegue, viewControllerIdentifier: artifactsVC, enabled: artifactsCount > 0),
            
            DisplayData(key: "Console Output", value: "", cellIdentifier: moreInfoBuildCell, segueIdentifier: Constants.Identifiers.showConsoleOutputSegue, viewControllerIdentifier: consoleOutputVC)
        ]
        
        nameLabel.text = build?.fullDisplayName ?? build?.displayName
        
        // This is not nice and I know it. Unfortunately, the Swift compiler gives up on compiling the above statement and this statement together on one line
        if nameLabel.text == nil{ nameLabel.text = "Build #" + ((build?.number != nil) ? "\(build!.number)" : "Unknown") }
        
        (navigationItem.titleView as? UIImageView)?.image = favoriteImage
        
        tableView.reloadData()
    }
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepare(viewController: segue.destination)
    }
    
    fileprivate func prepare(viewController: UIViewController){
        if let consoleOutputViewController = viewController as? ConsoleOutputViewController{
            guard let build = build, let account = account
                else { return }
            consoleOutputViewController.request = NetworkManager.manager.getConsoleOutputUserRequest(build: build, account: account)
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
        else if let artifactsViewController = viewController as? ArtifactsTableViewController{
            artifactsViewController.build = build
            artifactsViewController.account = account
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
        
        if displayData[indexPath.row].enabled && displayData[indexPath.row].cellIdentifier == Constants.Identifiers.moreInfoBuildCell{
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor =  UIColor.black
            cell.selectionStyle =  .default
        }
        else{
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.textLabel?.textColor = (displayData[indexPath.row].cellIdentifier == Constants.Identifiers.moreInfoBuildCell) ? UIColor.lightGray : UIColor.black
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let segueIdentifier = displayData[indexPath.row].segueIdentifier, displayData[indexPath.row].enabled{
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
