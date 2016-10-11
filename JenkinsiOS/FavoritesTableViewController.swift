//
//  FavoritesTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    var jobFavorites = ApplicationUserManager.manager.applicationUser.favorites.filter{ $0.type == .job}
    var buildFavorites = ApplicationUserManager.manager.applicationUser.favorites.filter{ $0.type == .build }
    
    var jobs: [(job: Job, account: Account)] = []
    var builds: [(build: Build, account: Account)] = []
    
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJobs()
        loadBuilds()
    }
    
    //MARK: - Data loading and presentation
    
    func loadJobs(){
        for jobFavorite in jobFavorites{
            if let account = jobFavorite.account{
                let userRequest = UserRequest(requestUrl: jobFavorite.url, account: account)
                NetworkManager.manager.getJob(userRequest: userRequest, completion: { (job, _) in
                    if let job = job{
                        self.jobs.append((job: job, account: account))
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        }
                    }
                })
            }
        }
    }
    
    func loadBuilds(){
        for buildFavorite in buildFavorites{
            if let account = buildFavorite.account{
                let userRequest = UserRequest(requestUrl: buildFavorite.url, account: account)
                NetworkManager.manager.getBuild(userRequest: userRequest, completion: { (build, _) in
                    if let build = build{
                        self.builds.append((build: build, account: account))
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                        }
                    }
                })
            }
        }
    }
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showJobSegue, let row = sender as? Int, let dest = segue.destination as? JobViewController{
            dest.job = jobs[row].job
            dest.account = jobs[row].account
        }
        else if segue.identifier == Constants.Identifiers.showBuildSegue, let row = sender as? Int, let dest = segue.destination as? BuildViewController{
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
