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
    
    typealias DisplayData = (key: String, value: String)
    var displayData: [DisplayData] = []
    
    private var favoriteImage: UIImage? {
        get{
            return (build != nil && build!.isFavorite) ? UIImage(named: "fav-fill") : UIImage(named: "fav")
        }
    }
    
    private let dateFormatter = DateFormatter()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpUI()
        setupDateFormatter()
        updateData()
        performRequests()
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
        navigationItem.rightBarButtonItem?.image = favoriteImage
    }
    
    //MARK: - Data loading and displaying
    
    private func performRequests(){
        guard let build = build, let account = account
            else { return }
        
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
    
    private func setUpUI(){        
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.staticBuildInfoCell)
        tableView.separatorStyle = .none
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(toggleLike))
        
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.tableHeaderView?.backgroundColor = Constants.UI.backgroundColor
        
        title = "Build"
    }
    
    func updateData(){
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
        
        displayData = [
            (key: "Result", value: resultString),
            (key: "ID", value: idString),
            (key: "Started", value: timeStampString),
            (key: "Duration", value: timeIntervalString),
            (key: "Estimated", value: estimatedTimeIntervalString),
            (key: "Building", value: buildingString),
            (key: "Built On", value: builtOnString)
        ]
        
        nameLabel.text = build?.fullDisplayName ?? build?.displayName ?? "Build #" + ((build?.number != nil) ? "\(build!.number)" : "Unknown")
        numberLabel.text = "Number: \((build?.number).textify())"
        
        resizeTableHeaderView()
        
        tableView.reloadData()
    }
    
    private func resizeTableHeaderView() {
        guard let header = tableView.tableHeaderView
            else { return }
        
        let size = header
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        header.frame = CGRect(origin: header.frame.origin, size: CGSize(width: header.frame.width, height: size.height))
    }
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepare(viewController: segue.destination)
    }
    
    fileprivate func prepare(viewController: UIViewController){
        if let consoleOutputViewController = viewController as? ConsoleOutputViewController {
            guard let build = build, let account = account
                else { return }
            consoleOutputViewController.request = NetworkManager.manager.getConsoleOutputUserRequest(build: build, account: account)
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : displayData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.buildCauseCell, for: indexPath) as! BuildCauseTableViewCell
            cell.build = build
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.staticBuildInfoCell, for: indexPath) as! DetailTableViewCell
        cell.titleLabel.text = displayData[indexPath.row].key
        cell.detailLabel.text = displayData[indexPath.row].value
        
        cell.container.borders = [.left, .right, .bottom]
        
        if indexPath.row == 0 {
            cell.container.cornersToRound = [.topLeft, .topRight]
            cell.container.borders.insert(.top)
        }
        else if indexPath.row == displayData.count - 1 {
            cell.container.cornersToRound = [.bottomLeft, .bottomRight]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 210 : 51
    }
}

extension BuildViewController: BuildsInformationOpeningDelegate {
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
