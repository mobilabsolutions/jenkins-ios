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
            if let account = account, !account.isEqual(oldValue) && folderJob == nil {
                userRequest = nil
                jobs = nil
                currentView = nil
                shouldReloadFavorites = true
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
            navigationItem.rightBarButtonItem = folderJob != nil ? favoriteBarButtonItem() : nil
            title = folderJob?.name ?? "Jobs"
        }
    }

    private var searchController: UISearchController?
    private var isInitialLoad = true
    private var shouldReloadFavorites = false

    private var currentFavoritesSection: AllFavoritesTableViewCell.FavoritesSections?

    /// The identifier and number of rows for a given section and a row in that section as well as the height for that row. Based on the current JobListResults
    private typealias SectionInformation = (identifier: String, rows: Int, rowHeight: CGFloat)
    private typealias SectionInformationClosure = (View?, FolderState) -> SectionInformation
    private lazy var sections: [SectionInformationClosure] = [
        { _, state in (Constants.Identifiers.favoritesHeaderCell, state == .noFolder ? 1 : 0, 72) },
        { _, state in (Constants.Identifiers.favoritesCell, state == .noFolder ? 1 : 0, 150) },
        { currentView, state in
            let numberOfRows: Int
            if currentView == nil {
                numberOfRows = 0
            } else if currentView?.jobResults.isEmpty == true && state != .folderMultiBranch && state != .noFolder {
                numberOfRows = 0
            } else {
                numberOfRows = 1
            }
            return (Constants.Identifiers.jobsHeaderCell, numberOfRows, 72)
        },
        { currentView, _ in (Constants.Identifiers.jobCell, currentView?.jobResults.count ?? 0, 74) },
    ]

    private enum FolderState {
        case folderNoMultiBranch
        case folderMultiBranch
        case noFolder
        case unknown

        init(jobList: JobList?, folderJob: Job?) {
            guard let list = jobList
            else { self = folderJob != nil ? .folderNoMultiBranch : .noFolder; return }
            if list.isMultibranch {
                self = .folderMultiBranch
            } else if folderJob != nil {
                self = .folderNoMultiBranch
            } else {
                self = .noFolder
            }
        }
    }

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let filteringHeaderViewNib = UINib(nibName: "FilteringHeaderTableViewCell", bundle: .main)

        tableView.register(filteringHeaderViewNib, forCellReuseIdentifier: Constants.Identifiers.favoritesHeaderCell)
        tableView.register(filteringHeaderViewNib, forCellReuseIdentifier: Constants.Identifiers.jobsHeaderCell)

        loadJobs()

        emptyTableView(for: .loading)
        contentType = .jobList

        updateMinimumLabelOffset()

        tableView.backgroundColor = Constants.UI.backgroundColor

        NotificationCenter.default.addObserver(self, selector: #selector(reloadFavorites), name: Constants.Identifiers.favoriteStatusToggledNotification, object: nil)

        setBottomContentInsetForOlderDevices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isUserInteractionEnabled = true
        searchController?.searchBar.text = ""
        tabBarController?.navigationItem.title = account?.displayName ?? "Jobs"

        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter")?.withRenderingMode(.alwaysOriginal),
                                                                              style: .plain, target: self, action: #selector(presentFilterDialog))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.navigationItem.rightBarButtonItem = nil
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

        emptyTableView(for: .loading)
        tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = false

        let folderStateBefore = FolderState(jobList: jobs, folderJob: folderJob)

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

                        self.emptyTableView(for: .error, action: self.defaultRefreshingAction)
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
                } else {
                    self.currentView = jobList?.allJobsView ?? jobList?.views.first
                }

                self.emptyTableView(for: .noData, action: self.defaultRefreshingAction)
                self.shouldReloadFavorites = true
                // If the folder state has changed, we might want to hide the favorites sections and therefore
                // we reload all data, while if it is the same, there won't be any changes in those sections.
                if folderStateBefore != FolderState(jobList: self.jobs, folderJob: self.folderJob) {
                    self.tableView.reloadData()
                } else {
                    self.tableView.reloadSections([2, 3], with: .automatic)
                }
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

        if #available(iOS 11.0, *) {
            tabBarController?.navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController?.searchBar
            tableView.contentOffset.y += tableView.tableHeaderView?.frame.height ?? 0
            searchController?.hidesNavigationBarDuringPresentation = false
            searchResultsController.tableView.contentInset.top += (navigationController?.navigationBar.frame.height ?? 0)
                + (searchController?.searchBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height
        }
    }

    private func getSearchData() -> [Searchable] {
        guard let jobs = jobs else { return [] }
        let jobResults: [JobListResult]
        if let allResults = jobs.allJobsView?.jobResults {
            jobResults = allResults
        } else {
            jobResults = jobs.views.flatMap { $0.jobResults }
        }

        return jobResults.map { job -> Searchable in
            Searchable(searchString: job.name, data: job as AnyObject) {
                self.searchController?.dismiss(animated: true, completion: { [unowned self] in
                    let identifier: String!

                    switch job {
                    case .folder:
                        identifier = Constants.Identifiers.showFolderSegue
                    case .job:
                        identifier = Constants.Identifiers.showJobSegue
                    }

                    self.performSegue(withIdentifier: identifier, sender: job)
                })
            }
        }
    }

    private func favoriteBarButtonItem() -> UIBarButtonItem? {
        guard let job = folderJob
        else { return nil }

        let imageName = !job.isFavorite ? "fav" : "fav-fill"

        let image = UIImage(named: imageName)
        return UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(favorite))
    }

    @objc private func favorite() {
        guard let account = account, let job = folderJob
        else { return }
        job.toggleFavorite(account: account)

        navigationItem.rightBarButtonItem?.image = UIImage(named: !job.isFavorite ? "fav" : "fav-fill")
    }

    // MARK: - Viewcontroller navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showJobSegue,
            let jobCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: jobCell),
            let jobResult = currentView?.jobResults[indexPath.row] {
            prepare(vc: segue.destination, for: jobResult)
        } else if segue.identifier == Constants.Identifiers.showJobSegue, let jobResult = sender as? JobListResult {
            prepare(vc: segue.destination, for: jobResult)
        } else if segue.identifier == Constants.Identifiers.showFolderSegue,
            let cell = sender as? UITableViewCell,
            let path = tableView.indexPath(for: cell),
            let jobResult = currentView?.jobResults[path.row] {
            prepare(vc: segue.destination, for: jobResult)
        } else if segue.identifier == Constants.Identifiers.showFolderSegue, let jobResult = sender as? JobListResult {
            prepare(vc: segue.destination, for: jobResult)
        } else if segue.identifier == Constants.Identifiers.showBuildSegue, let favoriteValues = sender as? (Favoratible, Favorite), let build = favoriteValues.0 as? Build, let dest = segue.destination as? BuildViewController {
            dest.build = build
            dest.account = favoriteValues.1.account ?? account
        } else if segue.identifier == Constants.Identifiers.showJobSegue, let favoriteValues = sender as? (Favoratible, Favorite),
            let favoritable = favoriteValues.0 as? Job {
            prepare(vc: segue.destination, for: .job(job: favoritable), account: favoriteValues.1.account)
        } else if segue.identifier == Constants.Identifiers.showFolderSegue, let favoriteValues = sender as? (Favoratible, Favorite), let favoritable = favoriteValues.0 as? Job {
            prepare(vc: segue.destination, for: .folder(folder: favoritable), account: favoriteValues.1.account)
        }
    }

    private func prepare(vc: UIViewController, for jobListResult: JobListResult, account: Account? = nil) {
        switch jobListResult {
        case let .folder(folder):
            prepare(vc: vc, forFolder: folder, account: account)
        case let .job(job):
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
        dest.title = folder.name
        dest.account = account
    }

    @objc private func reloadFavorites() {
        shouldReloadFavorites = true
        tableView.reloadSections([0, 1], with: .none)
    }

    private func updateMinimumLabelOffset() {
        let folderState = FolderState(jobList: jobs, folderJob: folderJob)
        minimumEmptyContainerOffset = sections[0 ... 1].reduce(0, { $0 + $1(self.currentView, folderState).rowHeight })
    }

    // MARK: - Tableview datasource and delegate

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return prepareCellWithIdentifier(identifier: sections[indexPath.section](currentView, FolderState(jobList: jobs, folderJob: folderJob)).identifier, indexPath: indexPath)
    }

    private func prepareCellWithIdentifier(identifier: String, indexPath: IndexPath) -> UITableViewCell {
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
        let options: [AllFavoritesTableViewCell.FavoritesSections] = [
            .all(count: ApplicationUserManager.manager.applicationUser.favorites.count),
            .job, .build,
        ]
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
        cell.options = [currentView == jobs.allJobsView ? "SHOW ALL (\(jobs.views.count))" : currentView?.description.uppercased() ?? "View"]
    }

    private func prepareCellForFavorites(cell: AllFavoritesTableViewCell) {
        if cell.loader == nil {
            cell.loader = FavoritesLoader(with: cell)
            cell.favorites = ApplicationUserManager.manager.applicationUser.favorites
        } else if shouldReloadFavorites || cell.favorites.count != ApplicationUserManager.manager.applicationUser.favorites.count {
            cell.favorites = ApplicationUserManager.manager.applicationUser.favorites
        }

        shouldReloadFavorites = false

        cell.delegate = self
        cell.currentSectionFilter = currentFavoritesSection ?? .all(count: cell.favorites.count)
    }

    private func prepareCellForJobListResult(cell: JobTableViewCell, indexPath: IndexPath) {
        guard let jobResult = currentView?.jobResults[indexPath.row]
        else { return }
        prepare(cell: cell, for: jobResult)
    }

    fileprivate func prepare(cell: JobTableViewCell, for jobResult: JobListResult) {
        cell.setup(with: jobResult)
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section](currentView, FolderState(jobList: jobs, folderJob: folderJob)).rows
    }

    override func numberOfSections() -> Int {
        return sections.count
    }

    override func tableViewIsEmpty() -> Bool {
        return sections.last!(currentView, FolderState(jobList: jobs, folderJob: folderJob)).rows == 0
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section](currentView, FolderState(jobList: jobs, folderJob: folderJob)).rowHeight
    }

    override func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Only select cells in the jobs section
        return indexPath.section == 3 || folderJob != nil ? indexPath : nil
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        guard children.isEmpty
        else { return }

        let valueSelectionViewController = ValueSelectionTableViewController<JobsTableViewController>()
        valueSelectionViewController.delegate = self
        valueSelectionViewController.selectedValue = currentView
        valueSelectionViewController.values = jobs?.views ?? []
        valueSelectionViewController.tableView.contentInset.bottom = 100

        addChild(valueSelectionViewController)
        view.addSubview(valueSelectionViewController.view)
        tableView.isScrollEnabled = false

        valueSelectionViewController.view.layer.cornerRadius = 15
        valueSelectionViewController.view.layer.masksToBounds = true

        valueSelectionViewController.view.translatesAutoresizingMaskIntoConstraints = false

        let jobsHeaderIndexPath = IndexPath(row: 0, section: 2)

        valueSelectionViewController.view.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 8).isActive = true
        valueSelectionViewController.view.widthAnchor.constraint(equalTo: tableView.widthAnchor, constant: -16).isActive = true
        valueSelectionViewController.view.heightAnchor.constraint(equalTo: tableView.heightAnchor,
                                                                  constant: -tableView.rectForRow(at: jobsHeaderIndexPath).maxY - 32).isActive = true

        valueSelectionViewController.view.topAnchor.constraint(equalTo: view.topAnchor,
                                                               constant: tableView.rectForRow(at: jobsHeaderIndexPath).maxY).isActive = true

        valueSelectionViewController.didMove(toParent: self)
    }

    @objc private func presentFilterDialog() {
        let alert = UIAlertController(title: "Sort", message: "Sort jobs by", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { _ in
            self.sortJobs(by: .date)
        }))
        alert.addAction(UIAlertAction(title: "Status", style: .default, handler: { _ in
            self.sortJobs(by: .status)
        }))
        alert.addAction(UIAlertAction(title: "Health", style: .default, handler: { _ in
            self.sortJobs(by: .health)
        }))

        present(alert, animated: true, completion: nil)
    }

    private func sortJobs(by option: JobSorter.JobSortingOption) {
        guard let views = jobs?.views
        else { return }

        let sorter = JobSorter()
        sorter.sortJobsInPlace(by: option, views: views)
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
        switch favorite.type {
        case .build:
            performSegue(withIdentifier: Constants.Identifiers.showBuildSegue, sender: (favoritable, favorite))
        case .job:
            performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: JobListResult.job(job: favoritable as! Job))
        case .folder:
            performSegue(withIdentifier: Constants.Identifiers.showFolderSegue, sender: JobListResult.folder(folder: favoritable as! Job))
        }
    }
}

extension JobsTableViewController: FilteringHeaderTableViewCellDelegate {
    func didDeselectAll() {
        // This should never happen
    }

    func didSelect(selected: CustomStringConvertible, cell _: FilteringHeaderTableViewCell) {
        if let selected = selected as? AllFavoritesTableViewCell.FavoritesSections {
            self.didSelectFavoriteSection(section: selected)
        } else {
            self.didSelectViewChangeButton()
        }
    }
}

extension JobsTableViewController: ValueSelectionTableViewControllerDelegate {
    typealias ValueSelectionTableViewControllerType = View
    func didSelect(value: JobsTableViewController.ValueSelectionTableViewControllerType) {
        self.currentView = value

        let child = self.children.first
        child?.willMove(toParent: nil)
        child?.view.removeFromSuperview()
        child?.removeFromParent()

        self.tableView.isScrollEnabled = true
        self.tableView.reloadSections([2, 3], with: .automatic)
    }
}
