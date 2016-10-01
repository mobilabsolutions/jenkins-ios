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
    var jobs: JobList?{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
            
        guard let account = account
            else { return }
        NetworkManager.manager.getJobs(userRequest: UserRequest(requestUrl: account.baseUrl, account: account, additionalQueryItems: Constants.API.jobListAdditionalQueryItems)) { (jobList, error) in
            //FIXME: Display an error message on error
            if error == nil && jobList != nil{
                self.jobs = jobList
            }
            else{
                print("Error: \(error)")
            }
        }
    }
    
    //MARK: - Viewcontroller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? JobViewController, segue.identifier == Constants.Identifiers.showJobSegue, let job = sender as? Job{
            dest.job = job
            dest.account = account
        }
    }
    
    //MARK: - Tableview datasource and delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.jobCell, for: indexPath)
        cell.textLabel?.text = jobs?.allJobs[indexPath.row].name
        cell.detailTextLabel?.text = jobs?.allJobs[indexPath.row].color?.rawValue ?? jobs?.allJobs[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs?.allJobs.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let job = jobs?.allJobs[indexPath.row]
            else { return }
        
        performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: job)
    }
}
