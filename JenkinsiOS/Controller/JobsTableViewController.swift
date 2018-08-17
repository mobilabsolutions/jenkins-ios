//
//  JobsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobsTableViewController: RefreshingTableViewController, AccountProvidable {
    var account: Account? {
        didSet {
            if account != nil && account != oldValue && folderJob == nil {
                userRequest = nil
                jobs = nil
                currentView = nil
                loadJobs()
                tableView.reloadData()
            }
        }
    }
    
    var userRequest: UserRequest?
    
    var jobs: JobList?
    var currentView: View?
    
    var folderJob: Job? {
        didSet {
            tabBarController?.navigationItem.rightBarButtonItem = folderJob != nil ? favoriteBarButtonItem() : nil
            self.title = folderJob?.name ?? "Jobs"
        }
    }
    
    private var searchController: UISearchController?
    private var isInitialLoad: Bool = true
    
    private var shouldReloadFavorites = false
    
    private var currentFavoritesSection: AllFavoritesTableViewCell.FavoritesSections?
    
    /// The identifier and number of rows for a given section and a row in that section as well as the height for that row. Based on the current JobListResults
    typealias SectionInformation = (identifier: String, rows: Int, rowHeight: CGFloat)
    typealias SectionInformationClosure = (Int?, [JobListResult]?) -> SectionInformation
    lazy var sections: [SectionInformationClosure] = [
        { _,_ in return (Constants.Identifiers.favoritesHeaderCell, 1, 72) },
        { _, _ in return (Constants.Identifiers.favoritesCell, 1, 160) },
        { _,_ in return (Constants.Identifiers.jobsHeaderCell, 1, 72) },
        {
        row, jobResults in
        guard let row = row, let jobResult = jobResults?[row]
        else { return ("", jobResults?.count ?? 0, 0) }
        
        return (Constants.Identifiers.jobCell, jobResults?.count ?? 0, 74)
    }]
        
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filteringHeaderViewNib = UINib(nibName: "FilteringHeaderTableViewCell", bundle: .main)
        
        self.tableView.register(filteringHeaderViewNib, forCellReuseIdentifier: Constants.Identifiers.favoritesHeaderCell)
        self.tableView.register(filteringHeaderViewNib, forCellReuseIdentifier: Constants.Identifiers.jobsHeaderCell)
        
        loadJobs()
        
        emptyTableView(for: .loading)
        contentType = .jobList
        
        self.tableView.backgroundColor = Constants.UI.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        searchController?.searchBar.text = ""
        self.tabBarController?.navigationItem.title = account?.displayName ?? "Jobs"
        
        // FIXME: Use correct image here
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(presentFilterDialog))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
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
        
        self.emptyTableView(for: .loading)
        self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = false
        
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
                
                self.emptyTableView(for: .noData)
                self.shouldReloadFavorites = true
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.setupSearchController()
                self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    private func setupSearchController() {
        let searchData = getSearchData()
        
        guard !searchData.isEmpty
        else { return }
        
        let searchResultsController = SearchResultsTableViewController(searchData: searchData, cellNib: UINib(nibName: "JobTableViewCell", bundle: .main))
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
        // FIXME: This needs to be adapted to the new UI design
        self.tabBarController?.navigationItem.rightBarButtonItem?.image = UIImage(named: !job.isFavorite ? "HeartEmpty" : "HeartFull")
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
        else if segue.identifier == Constants.Identifiers.showFolderSegue,
            let cell = sender as? UITableViewCell,
            let path = tableView.indexPath(for: cell),
            let jobResult = currentView?.jobResults[path.row] {
            prepare(vc: segue.destination, for: jobResult)
        }
        else if segue.identifier == Constants.Identifiers.showFolderSegue, let jobResult = sender as? JobListResult {
            prepare(vc: segue.destination, for: jobResult)
        }
        else if segue.identifier == Constants.Identifiers.showBuildSegue, let favoriteValues = sender as? (Favoratible, Favorite), let build = favoriteValues.0 as? Build, let dest = segue.destination as? BuildViewController {
            dest.build = build
            dest.account = favoriteValues.1.account ?? self.account
        }
        else if segue.identifier == Constants.Identifiers.showJobSegue, let favoriteValues = sender as? (Favoratible, Favorite),
            let favoritable = favoriteValues.0 as? Job {
            prepare(vc: segue.destination, for: .job(job: favoritable), account: favoriteValues.1.account)
        }
        else if segue.identifier == Constants.Identifiers.showFolderSegue, let favoriteValues = sender as? (Favoratible, Favorite),let favoritable = favoriteValues.0 as? Job {
            prepare(vc: segue.destination, for: .folder(folder: favoritable), account: favoriteValues.1.account)
        }
    }
    
    private func prepare(vc: UIViewController, for jobListResult: JobListResult, account: Account? = nil) {
        switch jobListResult {
            case .folder(let folder):
                prepare(vc: vc, forFolder: folder, account: account)
            case .job(let job):
                prepare(vc: vc, forJob: job, account: account)
        }
    }
    
    private func prepare(vc: UIViewController, forJob job: Job, account: Account?) {
        guard let dest = vc as? JobViewController
        else { return }
        
        dest.job = job
        dest.account = account ?? self.account
    }
    
    private func prepare(vc: UIViewController, forFolder folder: Job, account: Account?) {
        guard let dest = vc as? JobsTableViewController, let account = account ?? self.account
        else { return }
        
        dest.folderJob = folder
        dest.userRequest = UserRequest.userRequestForJobList(account: account, requestUrl: folder.url)
        let emptySection: SectionInformationClosure = { _, _ in ("empty", 0, 0) }
        dest.sections = [emptySection, sections.lazy.last!]
        dest.title = folder.name
        dest.account = account
    }
    
    // MARK: - Tableview datasource and delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return prepareCellWithIdentifier(identifier: sections[indexPath.section](indexPath.row, currentView?.jobResults).identifier, indexPath: indexPath)
    }
    
    private func prepareCellWithIdentifier(identifier: String, indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch identifier {
        case Constants.Identifiers.favoritesHeaderCell:
            prepareCellForFavoritesHeader(cell: cell as! FilteringHeaderTableViewCell)
        case Constants.Identifiers.favoritesCell:
            prepareCellForFavorites(cell: cell as! AllFavoritesTableViewCell)
        case Constants.Identifiers.jobsHeaderCell:
            prepareCellForJobsHeader(cell: cell as! FilteringHeaderTableViewCell)
        default:
            prepareCellForJobListResult(cell: cell as! JobTableViewCell, indexPath: indexPath)
        }
        
        return cell
    }
    
    private func prepareCellForFavoritesHeader(cell: FilteringHeaderTableViewCell) {
        let options: [AllFavoritesTableViewCell.FavoritesSections] = [.all(count: ApplicationUserManager.manager.applicationUser.favorites.count),
                        .job, .build]
        cell.options = options
        cell.title = "FAVORITES"
        cell.delegate = self
    }
    
    private func prepareCellForJobsHeader(cell: FilteringHeaderTableViewCell) {
        guard let jobs = jobs
            else { cell.options = []; return }
        
        cell.options = jobs.views
        cell.title = "JOBS"
        cell.delegate = self
        cell.options = [currentView == jobs.allJobsView ? "SHOW ALL (\(jobs.views.count))" : currentView?.name.uppercased() ?? "View"]
    }
    
    private func prepareCellForFavorites(cell: AllFavoritesTableViewCell) {
        if cell.loader == nil {
            cell.loader = FavoritesLoader(with: cell)
            cell.favorites = ApplicationUserManager.manager.applicationUser.favorites
        }
        else if shouldReloadFavorites {
            cell.favorites = ApplicationUserManager.manager.applicationUser.favorites
        }
        
        self.shouldReloadFavorites = false
        
        cell.delegate = self
        cell.currentSectionFilter = self.currentFavoritesSection ?? .all(count: cell.favorites.count)
    }
    
    private func prepareCellForJobListResult(cell: JobTableViewCell, indexPath: IndexPath){
        guard let jobResult = currentView?.jobResults[indexPath.row]
        else { return }
        prepare(cell: cell, for: jobResult)
    }
    
    fileprivate func prepare(cell: JobTableViewCell, for jobResult: JobListResult){
        cell.setup(with: jobResult)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section](indexPath.row, currentView?.jobResults).rowHeight
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Only select cells in the jobs section
        return indexPath.section == 3 || folderJob != nil ? indexPath : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // We only want to segue if a folder or job cell was selected
        guard indexPath.section > 0 && indexPath.row < currentView?.jobResults.count ?? 0, let job = currentView?.jobResults[indexPath.row]
            else { return }
        
        switch job {
        case .folder(folder: _):
            performSegue(withIdentifier: Constants.Identifiers.showFolderSegue, sender: job)
        case .job(job: _):
            performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: job)
        }
    }
    
    private func didSelectFavoriteSection(section: AllFavoritesTableViewCell.FavoritesSections) {
        currentFavoritesSection = section
        tableView.reloadSections([1], with: .automatic)
    }
    
    private func didSelectViewChangeButton() {
        
        guard self.childViewControllers.isEmpty
            else { return }
        
        let valueSelectionViewController = ValueSelectionTableViewController<JobsTableViewController>()
        valueSelectionViewController.delegate = self
        valueSelectionViewController.selectedValue = self.currentView
        valueSelectionViewController.values = self.jobs?.views ?? []
        
        addChildViewController(valueSelectionViewController)
        view.addSubview(valueSelectionViewController.view)
        self.tableView.isScrollEnabled = false
        
        valueSelectionViewController.view.layer.cornerRadius = 15
        valueSelectionViewController.view.layer.masksToBounds = true
        
        valueSelectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let jobsHeaderIndexPath = IndexPath(row: 0, section: 2)
        
        valueSelectionViewController.view.leftAnchor.constraint(equalTo: self.tableView.leftAnchor, constant: 8).isActive = true
        valueSelectionViewController.view.widthAnchor.constraint(equalTo: self.tableView.widthAnchor, constant: -16).isActive = true
        valueSelectionViewController.view.heightAnchor.constraint(equalTo: self.tableView.heightAnchor,
                                                                  constant: -self.tableView.rectForRow(at: jobsHeaderIndexPath).maxY - 32).isActive = true
        
        valueSelectionViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor,
                                                               constant: self.tableView.rectForRow(at: jobsHeaderIndexPath).maxY).isActive = true
        
        valueSelectionViewController.didMove(toParentViewController: self)
    }
    
    @objc private func presentFilterDialog() {
        let alert = UIAlertController(title: "Filter", message: "Filter jobs by", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { (_) in
            self.sortJobs(by: .date)
        }))
        alert.addAction(UIAlertAction(title: "Status", style: .default, handler: { (_) in
            self.sortJobs(by: .status)
        }))
        alert.addAction(UIAlertAction(title: "Health", style: .default, handler: { (_) in
            self.sortJobs(by: .health)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private enum JobSortingOption {
        case date
        case status
        case health
    }
    
    private func sortJobs(by option: JobSortingOption) {
        guard let views = jobs?.views
            else { return }
        
        for view in views {
            view.jobResults.sort(by: { (first, second) -> Bool in
                switch option {
                case .status:
                    guard let firstColor = first.color, let secondColor = second.color
                        else { return first.color != nil }
                    return firstColor < secondColor
                case .health:
                    guard let firstHealthReport = first.data.healthReport.first,
                        let secondHealthReport = second.data.healthReport.first
                        else { return first.data.healthReport.first != nil }
                    return firstHealthReport.score > secondHealthReport.score
                case .date:
                    guard let firstDate = first.data.lastBuild?.timeStamp,
                        let secondDate = second.data.lastBuild?.timeStamp
                        else { return first.data.lastBuild?.timeStamp != nil }
                    // Sort by date closest to now
                    return firstDate > secondDate
                }
            })
        }
        
        tableView.reloadSections([3], with: .automatic)
    }
}

extension JobsTableViewController: SearchResultsControllerDelegate {
    func setup(cell: UITableViewCell, for searchable: Searchable) {
        guard let jobListResult = searchable.data as? JobListResult
            else { return }
        prepare(cell: cell as! JobTableViewCell, for: jobListResult)
    }
}

extension JobsTableViewController: AllFavoritesTableViewCellDelegate {
    func didSelectErroredFavorite(favorite: Favorite) {
        UIApplication.shared.openURL(favorite.url)
    }
    
    func didSelectLoadedFavoritable(favoritable: Favoratible, for favorite: Favorite) {
        switch favorite.type{
        case .build:
            performSegue(withIdentifier: Constants.Identifiers.showBuildSegue, sender: (favoritable, favorite))
        case .job:
            performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: JobListResult.job(job: favoritable as! Job))
        case .folder:
            performSegue(withIdentifier: Constants.Identifiers.showFolderSegue, sender: JobListResult.job(job: favoritable as! Job))
        }
    }
}

extension JobsTableViewController: FilteringHeaderTableViewCellDelegate {
    func didDeselectAll() {
        // This should never happen
    }
    
    func didSelect(selected: CustomStringConvertible, cell: FilteringHeaderTableViewCell) {
        if let selected = selected as? AllFavoritesTableViewCell.FavoritesSections {
            self.didSelectFavoriteSection(section: selected)
        }
        else {
            self.didSelectViewChangeButton()
        }
    }
}

extension JobsTableViewController: ValueSelectionTableViewControllerDelegate {
    typealias ValueSelectionTableViewControllerType = View
    func didSelect(value: JobsTableViewController.ValueSelectionTableViewControllerType) {
        self.currentView = value
        
        let child = self.childViewControllers.first
        child?.willMove(toParentViewController: nil)
        child?.view.removeFromSuperview()
        child?.removeFromParentViewController()
        
        self.tableView.isScrollEnabled = true
        self.tableView.reloadSections([2, 3], with: .automatic)
    }
}

extension JenkinsColor: Comparable {
    static func < (lhs: JenkinsColor, rhs: JenkinsColor) -> Bool {
        return lhs.priorityForColor() > rhs.priorityForColor()
    }
    
    private func priorityForColor() -> Int {
        switch self {
        case .aborted: fallthrough
        case .abortedAnimated: return 0
        case .disabled: fallthrough
        case .disabledAnimated: return 1
        case .notBuilt: fallthrough
        case .notBuiltAnimated: return 2
        case .red: fallthrough
        case .redAnimated: return 3
        case .yellow: fallthrough
        case .yellowAnimated: return 4
        case .folder: return 5
        case .blue: fallthrough
        case .blueAnimated: return 6
        }
    }
}
