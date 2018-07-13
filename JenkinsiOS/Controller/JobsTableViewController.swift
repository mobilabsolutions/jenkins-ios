//
//  JobsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobsTableViewController: RefreshingTableViewController {
    var account: Account?
    var userRequest: UserRequest?
    
    var jobs: JobList?
    var currentView: View?
    
    var viewPicker: UIPickerView!
    
    var folderJob: Job? {
        didSet {
            navigationItem.rightBarButtonItem = folderJob != nil ? favoriteBarButtonItem() : nil
            self.title = folderJob?.name ?? "Jobs"
        }
    }
    
    private var searchController: UISearchController?
    private var isInitialLoad: Bool = true
    
    /// The identifier and number of rows for a given section and a row in that section. Based on the current JobListResults
    lazy var sections: [(Int?, [JobListResult]?) -> (identifier: String, rows: Int)] = [{ _, _ in (Constants.Identifiers.jenkinsCell, self.jenkinsCellSegues.count) }, {
        row, jobResults in
        guard let row = row, let jobResult = jobResults?[row]
        else { return ("", jobResults?.count ?? 0) }
        
        switch jobResult {
            case .job: return (Constants.Identifiers.jobCell, jobResults?.count ?? 0)
            case .folder: return (Constants.Identifiers.folderCell, jobResults?.count ?? 0)
        }
    }]
    
    let jenkinsCellSegues = [("Build Queue", Constants.Identifiers.showBuildQueueSegue), ("Jenkins Settings", Constants.Identifiers.showJenkinsSegue)]
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJobs()
        setUpPicker()
        
        emptyTableView(for: .loading)
        title = title ?? account?.displayName ?? "Jobs"
        contentType = .jobList
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController?.searchBar.text = ""
    }
    
    override func refresh() {
        loadJobs()
        emptyTableView(for: .loading)
    }
    
    // MARK: - Data loading and displaying
    
    /// Load the jobs from the remote server
    @objc private func loadJobs() {        
        guard let account = account
        else { return }
        
        userRequest = userRequest ?? UserRequest.userRequestForJobList(account: account)
        
        _ = NetworkManager.manager.getJobs(userRequest: userRequest!) { jobList, error in
            
            DispatchQueue.main.async {
                guard jobList != nil && error == nil
                else {
                    if let error = error {
                        self.displayNetworkError(error: error, onReturnWithTextFields: { returnData in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!
                            
                            self.loadJobs()
                        })
                        
                        self.emptyTableView(for: .error)
                    }
                    
                    self.refreshControl?.endRefreshing()
                    return
                }
                
                self.jobs = jobList
                let filterViews: (View) -> Bool = {
                    $0.name == self.currentView?.name && $0.url == self.currentView?.url
                }
                if let view = jobList?.views.filter(filterViews).first {
                    self.currentView = view
                }
                else {
                    self.currentView = jobList?.allJobsView ?? jobList?.views.first
                }
                
                self.viewPicker.reloadAllComponents()
                if self.isInitialLoad {
                    self.isInitialLoad = false
                    self.scrollToInitialPickerView()
                }
                self.emptyTableView(for: .noData)
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.setupSearchController()
            }
        }
    }
    
    private func setupSearchController() {
        let searchData = getSearchData()
        
        guard !searchData.isEmpty
        else { return }
        
        let searchResultsController = SearchResultsTableViewController(searchData: searchData)
        searchResultsController.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController?.searchResultsUpdater = searchResultsController.searcher
        tableView.tableHeaderView = searchController?.searchBar
        tableView.contentOffset.y += tableView.tableHeaderView?.frame.height ?? 0
    }
    
    private func getSearchData() -> [Searchable] {
        guard let jobs = jobs else { return [] }
        let jobResults: [JobListResult]
        if let allResults = jobs.allJobsView?.jobResults {
            jobResults = allResults
        }
        else {
            jobResults = jobs.views.flatMap { $0.jobResults }
        }
        
        return jobResults.map { (job) -> Searchable in
            Searchable(searchString: job.name, data: job as AnyObject) {
                self.searchController?.dismiss(animated: true, completion: nil)
                
                let identifier: String!
                
                switch job {
                    case .folder:
                        identifier = Constants.Identifiers.showFolderSegue
                    case .job:
                        identifier = Constants.Identifiers.showJobSegue
                }
                
                self.performSegue(withIdentifier: identifier, sender: job)
            }
        }
    }
    
    private func setUpPicker() {
        viewPicker = UIPickerView()
        viewPicker.dataSource = self
        viewPicker.delegate = self
        viewPicker.backgroundColor = UIColor.clear
    }
    
    private func scrollToInitialPickerView() {
        if let jobs = jobs, let currentView = currentView, let index = jobs.views.index(where: { $0.name == currentView.name }) {
            viewPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    private func favoriteBarButtonItem() -> UIBarButtonItem? {
        guard let job = folderJob
        else { return nil }
        
        let imageName = !job.isFavorite ? "HeartEmpty" : "HeartFull"
        
        let image = UIImage(named: imageName)
        return UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(favorite))
    }
    
    @objc private func favorite() {
        guard let account = account, let job = folderJob
            else { return }
        job.toggleFavorite(account: account)
        navigationItem.rightBarButtonItem?.image = UIImage(named: !job.isFavorite ? "HeartEmpty" : "HeartFull")
    }
    
    // MARK: - Viewcontroller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showJobSegue,
            let jobCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: jobCell),
            let jobResult = currentView?.jobResults[indexPath.row] {
            prepare(vc: segue.destination, for: jobResult)
        }
        else if segue.identifier == Constants.Identifiers.showJobSegue, let jobResult = sender as? JobListResult {
            prepare(vc: segue.destination, for: jobResult)
        }
        else if let dest = segue.destination as? BuildQueueTableViewController, segue.identifier == Constants.Identifiers.showBuildQueueSegue {
            dest.account = account
        }
        else if let dest = segue.destination as? JenkinsInformationTableViewController, segue.identifier == Constants.Identifiers.showJenkinsSegue {
            dest.account = account
        }
        else if segue.identifier == Constants.Identifiers.showFolderSegue,
            let cell = sender as? UITableViewCell,
            let path = tableView.indexPath(for: cell),
            let jobResult = currentView?.jobResults[path.row] {
            prepare(vc: segue.destination, for: jobResult)
        }
        else if segue.identifier == Constants.Identifiers.showFolderSegue, let jobResult = sender as? JobListResult {
            prepare(vc: segue.destination, for: jobResult)
        }
    }
    
    private func prepare(vc: UIViewController, for jobListResult: JobListResult) {
        switch jobListResult {
            case .folder(let folder):
                prepare(vc: vc, forFolder: folder)
            case .job(let job):
                prepare(vc: vc, forJob: job)
        }
    }
    
    private func prepare(vc: UIViewController, forJob job: Job) {
        guard let dest = vc as? JobViewController
        else { return }
        
        dest.job = job
        dest.account = account
    }
    
    private func prepare(vc: UIViewController, forFolder folder: Job) {
        guard let dest = vc as? JobsTableViewController, let account = self.account
        else { return }
        
        dest.account = account
        dest.userRequest = UserRequest.userRequestForJobList(account: account, requestUrl: folder.url)
        let emptySection: (Int?, [JobListResult]?) -> (String, Int) = { _, _ in ("empty", 0) }
        dest.sections = [emptySection, sections.lazy.last!]
        dest.title = folder.name
        dest.folderJob = folder
    }
    
    // MARK: - Tableview datasource and delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections[indexPath.section](indexPath.row, currentView?.jobResults).identifier == Constants.Identifiers.jenkinsCell {
            performSegue(withIdentifier: jenkinsCellSegues[indexPath.row].1, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = sections[indexPath.section](indexPath.row, currentView?.jobResults).identifier
        return prepareCellWithIdentifier(identifier: identifier, indexPath: indexPath)
    }
    
    private func prepareCellWithIdentifier(identifier: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch identifier {
            case Constants.Identifiers.jobCell, Constants.Identifiers.folderCell:
                prepareCellForJobListResult(cell: cell, indexPath: indexPath)
            case Constants.Identifiers.jenkinsCell:
                prepareCellForJenkins(cell: cell, indexPath: indexPath)
            default: return cell
        }
        
        return cell
    }
    
    private func prepareCellForJobListResult(cell: UITableViewCell, indexPath: IndexPath) {
        guard let jobResult = currentView?.jobResults[indexPath.row]
        else { return }
        prepare(cell: cell, for: jobResult)
    }
    
    fileprivate func prepare(cell: UITableViewCell, for jobResult: JobListResult) {
        cell.textLabel?.text = jobResult.name
        cell.detailTextLabel?.text = jobResult.description
        
        if let color = jobResult.color {
            cell.imageView?.image = UIImage(named: color.rawValue + "Circle")
        }
    }
    
    private func prepareCellForJenkins(cell: UITableViewCell, indexPath: IndexPath) {
        cell.textLabel?.text = jenkinsCellSegues[indexPath.row].0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section](nil, currentView?.jobResults).rows
    }
    
    override func numberOfSections() -> Int {
        return sections.count
    }
    
    override func tableViewIsEmpty() -> Bool {
        return sections.last!(nil, currentView?.jobResults).rows == 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let jobs = jobs,
            jobs.views.count > 1,
            section == 1
        else { return nil }
        
        let viewPickerSuperView = UIView()
        
        viewPicker.frame = viewPickerSuperView.bounds
        viewPicker.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if UIAccessibilityIsReduceTransparencyEnabled() == false {
            let effect = UIBlurEffect(style: .light)
            let effectView = UIVisualEffectView(effect: effect)
            
            effectView.frame = viewPicker.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            viewPickerSuperView.addSubview(effectView)
        }
        
        viewPickerSuperView.addSubview(viewPicker)
        
        viewPicker.translatesAutoresizingMaskIntoConstraints = false
        
        viewPicker.leftAnchor.constraint(equalTo: viewPickerSuperView.leftAnchor).isActive = true
        viewPicker.rightAnchor.constraint(equalTo: viewPickerSuperView.rightAnchor).isActive = true
        viewPicker.bottomAnchor.constraint(equalTo: viewPickerSuperView.bottomAnchor).isActive = true
        viewPicker.topAnchor.constraint(equalTo: viewPickerSuperView.topAnchor).isActive = true
        
        return viewPickerSuperView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let jobs = jobs,
            jobs.views.count > 1,
            section == 1
        else { return 0 }
        return 100
    }
}

extension JobsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return jobs?.views.count ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let jobs = jobs else { return nil }
        switch jobs.views[row].name {
            case "change-requests" where jobs.isMultibranch:
                return "Pull Requests"
            case "default" where jobs.isMultibranch:
                return "Branches"
            default:
                return jobs.views[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentView = jobs?.views[row]
        tableView.reloadData()
    }
}

extension JobsTableViewController: SearchResultsControllerDelegate {
    func setup(cell: UITableViewCell, for searchable: Searchable) {
        guard let jobListResult = searchable.data as? JobListResult
        else { return }
        prepare(cell: cell, for: jobListResult)
    }
}
