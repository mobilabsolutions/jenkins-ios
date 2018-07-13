//
//  FavoritesTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import SafariServices

class FavoritesTableViewController: RefreshingTableViewController, FavoritesLoading {

    var favoritesLoader: FavoritesLoader?
    var favorites = ApplicationUserManager.manager.applicationUser.favorites

    var numberOfJobs: Int {
        return ApplicationUserManager.manager.applicationUser.favorites.filter({ $0.type == .job || $0.type == .folder }).count
    }

    var loadedJobs: [(favoritable: Favoratible, favorite: Favorite)] = []
    var loadedBuilds: [(favoritable: Favoratible, favorite: Favorite)] = []

    var failedLoadingJobs: [Favorite] = []
    var failedLoadingBuilds: [Favorite] = []

    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleView()

        favoritesLoader = FavoritesLoader(with: self)
        favoritesLoader?.loadFavorites(favorites: favorites)

        registerForPreviewing(with: self, sourceView: tableView)
        
        title = "Favorites"
        emptyTableView(for: .noData)
        contentType = .favorites
    }

    override func refresh(){
        reloadAllFavorites()
    }

    //MARK: - Data loading and presentation
    

    @objc private func reloadAllFavorites(){
        loadedJobs = []
        loadedBuilds = []
        failedLoadingJobs = []
        failedLoadingBuilds = []

        favorites = ApplicationUserManager.manager.applicationUser.favorites

        tableView.reloadData()
        favoritesLoader?.loadFavorites(favorites: favorites)
    }

    func didLoadFavorite(favoritable: Favoratible, from favorite: Favorite) {
        switch favorite.type{
            case .job, .folder:
                loadedJobs.append((favoritable, favorite))
                tableView.reloadRows(at: [IndexPath(row: loadedJobs.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
            case .build:
                loadedBuilds.append((favoritable, favorite))
                tableView.reloadRows(at: [IndexPath(row: loadedBuilds.count - 1, section: 1)], with: UITableViewRowAnimation.automatic)
        }

        conditionallyEndRefreshing()
    }

    func didFailToLoad(favorite: Favorite, reason: FavoriteLoadingFailure) {
        switch favorite.type {
            case .build:
                let numberOfBuilds = (favorites.count - numberOfJobs)
                failedLoadingBuilds.append(favorite)
                tableView.reloadRows(at: [IndexPath(row: numberOfBuilds - failedLoadingBuilds.count, section: 1)], with: UITableViewRowAnimation.automatic)
            case .job, .folder:
                failedLoadingJobs.append(favorite)
                tableView.reloadRows(at: [IndexPath(row: numberOfJobs - failedLoadingJobs.count, section: 0)], with: UITableViewRowAnimation.automatic)
        }
    }

    private func conditionallyEndRefreshing(){
        // Make sure there are no more builds or jobs that are currently loading
        guard loadedJobs.count + loadedBuilds.count + failedLoadingBuilds.count + failedLoadingJobs.count >= favorites.count
                else { return }

        self.refreshControl?.endRefreshing()
        (navigationItem.titleView as? UIActivityIndicatorView)?.stopAnimating()
        navigationItem.titleView = nil
    }

    fileprivate func loadingState(for indexPath: IndexPath) -> FavoriteLoadingState{
        let isJob = indexPath.section == 0
        let failedForType = isJob ? failedLoadingJobs : failedLoadingBuilds
        let succeededForType = isJob ? loadedJobs : loadedBuilds
        let numberOfItemsForType = isJob ? numberOfJobs : favorites.count - numberOfJobs

        if indexPath.row < succeededForType.count{
            return .loaded(favoritable: succeededForType[indexPath.row].favoritable)
        }
        else if indexPath.row >= numberOfItemsForType - failedForType.count{
            return .errored
        }
        return .loading
    }

    private func setupTitleView(){
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        navigationItem.titleView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    override func tableViewIsEmpty() -> Bool {
        return favorites.count == 0
    }

    private func favorite(for indexPath: IndexPath) -> Favorite?{
        let isJob = indexPath.section == 0
        let failedForType = isJob ? failedLoadingJobs : failedLoadingBuilds
        let succeededForType = isJob ? loadedJobs : loadedBuilds
        let numberOfItemsForType = isJob ? numberOfJobs : favorites.count - numberOfJobs

        if indexPath.row < succeededForType.count {
            return succeededForType[indexPath.row].favorite
        }
        else if indexPath.row >= numberOfItemsForType - failedForType.count {
            return failedForType[indexPath.row - (numberOfItemsForType - failedForType.count)]
        }
        return nil
    }

    private func unfavorite(favoriteAt indexPath: IndexPath){
        guard let favorite = self.favorite(for: indexPath)
                else { return }
        guard let index = ApplicationUserManager.manager.applicationUser.favorites.index(of: favorite)
                else { return }
        ApplicationUserManager.manager.applicationUser.favorites.remove(at: index)
        LoggingManager.loggingManager.logunfavoritedFavoritable(type: favorite.type)
        ApplicationUserManager.manager.save()

        self.favorites = ApplicationUserManager.manager.applicationUser.favorites

        switch favorite.type{
            case .build: unfavoriteBuild(favorite: favorite)
            case .job, .folder: unfavoriteJob(favorite: favorite)
        }

        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        self.tableView.endUpdates()
    }

    private func unfavoriteBuild(favorite: Favorite){
        if let index = loadedBuilds.index(where: { tuple in tuple.1 == favorite } ){
            loadedBuilds.remove(at: index)
        }
        else if let index = failedLoadingBuilds.index(where: { failedFavorite in  failedFavorite == favorite } ){
            failedLoadingBuilds.remove(at: index)
        }
    }

    private func unfavoriteJob(favorite: Favorite){
        if let index = loadedJobs.index(where: { tuple in tuple.1 == favorite } ){
            loadedJobs.remove(at: index)
        }
        else if let index = failedLoadingJobs.index(where: { failedFavorite in  failedFavorite == favorite } ){
            failedLoadingJobs.remove(at: index)
        }
    }

    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showJobSegue, let row = sender as? Int {
            prepareViewController(viewController: segue.destination, row: row, type: .job)
        }
        else if segue.identifier == Constants.Identifiers.showBuildSegue, let row = sender as? Int {
            prepareViewController(viewController: segue.destination, row: row, type: .build)
        }
        if segue.identifier == Constants.Identifiers.showJobsSegue, let row = sender as? Int {
            prepareViewController(viewController: segue.destination, row: row, type: .folder)
        }
    }
    
    func prepareViewController(viewController: UIViewController, row: Int, type: Favorite.FavoriteType){

        if case .loaded(_) = loadingState(for: IndexPath(row: row, section: type == .job || type == .folder ? 0 : 1)){
            if type == .job, let dest = viewController as? JobViewController {
                dest.job = loadedJobs[row].favoritable as? Job
                dest.account = loadedJobs[row].favorite.account
            }
            else if type == .build, let dest = viewController as? BuildViewController {
                dest.build = loadedBuilds[row].favoritable as? Build
                dest.account = loadedBuilds[row].favorite.account
            }
            else if type == .folder, let dest = viewController as? JobsTableViewController {
                guard let account = loadedJobs[row].favorite.account, let folder = loadedJobs[row].favoritable as? Job
                    else { return }
                dest.userRequest = UserRequest.userRequestForJobList(account: account, requestUrl: folder.url)
                dest.folderJob = folder
                dest.account = account
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch loadingState(for: indexPath) {
            case .loaded(_):
                if indexPath.section == 0 && favorites[indexPath.row].type == .job {
                    performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: indexPath.row)
                }
                else if indexPath.section == 0 && favorites[indexPath.row].type == .folder {
                    performSegue(withIdentifier: Constants.Identifiers.showJobsSegue, sender: indexPath.row)
                }
                else if indexPath.section == 1 {
                    performSegue(withIdentifier: Constants.Identifiers.showBuildSegue, sender: indexPath.row)
                }
            case .errored:
                guard let favorite = favorite(for: indexPath)
                        else { return }
                
                let favoriteUrlComponents = URLComponents(url: favorite.url, resolvingAgainstBaseURL: false)
                guard favoriteUrlComponents?.scheme == "http" || favoriteUrlComponents?.scheme == "https"
                        else { return }
                
                let safariVC = SFSafariViewController(url: favorite.url)
                present(safariVC, animated: true)
            case .loading: return
        }
    }
    
    override func numberOfSections() -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0: return numberOfJobs
            case 1: return favorites.count - numberOfJobs
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
            case 0: return numberOfJobs > 0 ? "Jobs" : nil
            case 1: return (favorites.count - numberOfJobs) > 0 ? "Builds" : nil
            default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.favoritesCell, for: indexPath)

        let isJob = indexPath.section == 0

        switch loadingState(for: indexPath){
            case .loaded(let favoritable):
                prepare(cell: cell, for: favoritable)
            case .loading:
                prepareForLoading(cell: cell, type: isJob ? .job : .build)
            case .errored:
                prepareForErrored(cell: cell, favorite: favorite(for: indexPath))
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "Unfavorite") { action, indexPath in
                self.unfavorite(favoriteAt: indexPath)
            }
        ]
    }


    private func prepare(cell: UITableViewCell, for favoritable: Favoratible){

        cell.textLabel?.textColor = .black
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default

        if let job = favoritable as? Job{
            prepare(cell: cell, for: job)
        }
        else if let build = favoritable as? Build{
            prepare(cell: cell, for: build)
        }
    }

    private func prepare(cell: UITableViewCell, for job: Job){
        cell.textLabel?.text = job.name
        if let color = job.color?.rawValue{
            cell.imageView?.image = UIImage(named: "\(color)Circle")
        }
    }

    private func prepare(cell: UITableViewCell, for build: Build){
        cell.textLabel?.text = build.fullDisplayName ?? build.displayName ?? "Build #\(build.number)"

        if let color = build.result?.lowercased(){
            cell.imageView?.image = UIImage(named: "\(color)Circle")
        }
    }

    private func prepareForErrored(cell: UITableViewCell, favorite: Favorite?){
        cell.imageView?.image = nil

        if let favorite = favorite{
            cell.textLabel?.text = "Failed loading " + ((favorite.type == .build) ? "Build" : "Job") + ": \(favorite.url)"
        }

        cell.textLabel?.textColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
    }

    private func prepareForLoading(cell: UITableViewCell, type: Favorite.FavoriteType){
        cell.imageView?.image = nil
        cell.textLabel?.text = "Loading "  + ((type == .build) ? "Build" : "Job") + "..."
        cell.textLabel?.textColor = .lightGray
        cell.accessoryType = .none
        cell.selectionStyle = .none
    }
}

extension FavoritesTableViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location)
            else { return nil }

        if case .loaded(_) = loadingState(for: indexPath) {

            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

            let appDelegate = UIApplication.shared.delegate as? AppDelegate

            if indexPath.section == 0 {
                guard let viewController = appDelegate?.getViewController(name: "JobViewController")
                        else {
                    return nil
                }
                prepareViewController(viewController: viewController, row: indexPath.row, type: .job)
                return viewController

            } else if indexPath.section == 1 {
                guard let viewController = appDelegate?.getViewController(name: "BuildViewController")
                        else {
                    return nil
                }
                prepareViewController(viewController: viewController, row: indexPath.row, type: .build)
                return viewController
            }
        }

        return nil
    }
}
