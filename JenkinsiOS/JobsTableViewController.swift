//
//  JobsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobsTableViewController: UITableViewController{
    var account: Account?
    var jobs: JobList?
    
    override func viewDidLoad() {
        loadJobs()
    }
    
    func loadJobs(){
        guard let account = account
            else { return }
        NetworkManager.manager.getJobs(userRequest: UserRequest(requestUrl: account.baseUrl, account: account, additionalQueryItems: Constants.API.jobListAdditionalQueryItems)) { (jobList, error) in
            //FIXME: Display an error message on error
            if error == nil && jobList != nil{
                self.jobs = jobList
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            else{
                print("Error: \(error)")
            }
        }

    }
    
    //MARK: - Viewcontroller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? JobViewController, segue.identifier == Constants.Identifiers.showJobSegue, let jobCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: jobCell), let job = jobs?.allJobsView?.jobs[indexPath.row]{
            dest.job = job
            dest.account = account
        }
    }
    
    //MARK: - Tableview datasource and delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.jobCell, for: indexPath)
        cell.textLabel?.text = jobs?.allJobsView?.jobs[indexPath.row].name
        cell.detailTextLabel?.text = jobs?.allJobsView?.jobs[indexPath.row].color?.rawValue ?? jobs?.allJobsView?.jobs[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs?.allJobsView?.jobs.count ?? 0
    }
}
