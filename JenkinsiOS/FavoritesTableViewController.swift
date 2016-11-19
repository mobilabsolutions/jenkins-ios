//
//  FavoritesTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class FavoritesTableViewController: RefreshingTableViewController {
    
    var jobFavorites = ApplicationUserManager.manager.applicationUser.favorites.filter{ $0.type == .job}
    var buildFavorites = ApplicationUserManager.manager.applicationUser.favorites.filter{ $0.type == .build }
    
    var jobs: [(job: Job, account: Account)] = []
    var builds: [(build: Build, account: Account)] = []
    
    var requestedFavorites: [URL] = []
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleView()
    
        loadJobs()
        loadBuilds()
        
        registerForPreviewing(with: self, sourceView: tableView)
        
        title = "Favorites"
    }

    override func refresh(){
        reloadAllFavorites()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        jobFavorites = ApplicationUserManager.manager.applicationUser.favorites.filter{ $0.type == .job}
        buildFavorites = ApplicationUserManager.manager.applicationUser.favorites.filter{ $0.type == .build }
        
        loadJobs()
        loadBuilds()
    }
    
    //MARK: - Data loading and presentation
    
    func loadJobs(){
        for jobFavorite in jobFavorites{
            if let account = jobFavorite.account, !requestedFavorites.contains(jobFavorite.url){
                requestedFavorites.append(jobFavorite.url)
                let userRequest = UserRequest(requestUrl: jobFavorite.url, account: account)
                NetworkManager.manager.getJob(userRequest: userRequest, completion: { (job, _) in
                    if let job = job{
                        self.jobs.append((job: job, account: account))
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.conditionallyEndRefreshing()
                        }
                    }
                })
            }
        }
        conditionallyEndRefreshing()
    }
    
    func loadBuilds(){
        for buildFavorite in buildFavorites{
            if let account = buildFavorite.account, !requestedFavorites.contains(buildFavorite.url){
                let userRequest = UserRequest(requestUrl: buildFavorite.url, account: account)
                requestedFavorites.append(buildFavorite.url)
                NetworkManager.manager.getBuild(userRequest: userRequest, completion: { (build, _) in
                    if let build = build{
                        self.builds.append((build: build, account: account))
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.conditionallyEndRefreshing()
                        }
                    }
                })
            }
        }
        conditionallyEndRefreshing()
    }
    
    @objc private func reloadAllFavorites(){
        requestedFavorites = []
        jobs = []
        builds = []
        tableView.reloadData()
        loadJobs()
        loadBuilds()
    }
    
    private func conditionallyEndRefreshing(){
        if jobFavorites.count == jobs.count && builds.count == buildFavorites.count{
            self.refreshControl?.endRefreshing()
            (navigationItem.titleView as? UIActivityIndicatorView)?.stopAnimating()
            navigationItem.titleView = nil
        }
    }
    
    private func setupTitleView(){
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        navigationItem.titleView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showJobSegue, let row = sender as? Int{
            prepareViewController(viewController: segue.destination, row: row, type: .job)
        }
        else if segue.identifier == Constants.Identifiers.showBuildSegue, let row = sender as? Int{
            prepareViewController(viewController: segue.destination, row: row, type: .build)
        }
    }
    
    func prepareViewController(viewController: UIViewController, row: Int, type: Favorite.FavoriteType){
        if type == .job, let dest = viewController as? JobViewController{
            dest.job = jobs[row].job
            dest.account = jobs[row].account
        }
        else if type == .build, let dest = viewController as? BuildViewController{
            dest.build = builds[row].build
            dest.account = builds[row].account
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: indexPath.row)
        }
        else if indexPath.section == 1{
            performSegue(withIdentifier: Constants.Identifiers.showBuildSegue, sender: indexPath.row)
        }
    }
    
    override func numberOfSections() -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0: return jobs.count
            case 1: return builds.count
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
            case 0: return "Jobs"
            case 1: return "Builds"
            default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.favoritesCell, for: indexPath)
        
        if indexPath.section == 1{
            let build = builds[indexPath.row].build
            cell.textLabel?.text = build.fullDisplayName ?? build.displayName ?? "Build #\(build.number)"
            
            if let color = build.result?.lowercased(){
                cell.imageView?.image = UIImage(named: "\(color)Circle")
            }
        }
        else if indexPath.section == 0{
            let job = jobs[indexPath.row].job
            cell.textLabel?.text = job.name
            if let color = job.color?.rawValue{
                cell.imageView?.image = UIImage(named: "\(color)Circle")
            }
        }
        
        return cell
    }
}

extension FavoritesTableViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location){
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            if indexPath.section == 0{
                guard let viewController = appDelegate?.getViewController(name: "JobViewController")
                    else { return nil }
                prepareViewController(viewController: viewController, row: indexPath.row, type: .job)
                return viewController
                
            }
            else if indexPath.section == 1{
                guard let viewController = appDelegate?.getViewController(name: "BuildViewController")
                    else { return nil }
                prepareViewController(viewController: viewController, row: indexPath.row, type: .build)
                return viewController
            }
            return nil
        }
        return nil
    }
}
