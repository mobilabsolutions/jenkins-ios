//
//  JobsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobsTableViewController: UITableViewController {
    var account: Account?
    var jobs: JobList?{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        print(account)
        guard let account = account
            else { return }
        //FIXME: Init with different tree
        NetworkManager.manager.getJobs(userRequest: UserRequest(requestUrl: account.baseUrl, account: account)) { (jobList, error) in
            //FIXME: Display an error message on error
            if error == nil && jobList != nil{
                self.jobs = jobList
            }
            else{
                print("Error: \(error)")
            }
        }
    }
    
    //MARK: Tableview datasource and delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.jobCell, for: indexPath)
        cell.textLabel?.text = jobs?.jobs[indexPath.row].name
        cell.detailTextLabel?.text = jobs?.jobs[indexPath.row].color?.rawValue ?? jobs?.jobs[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs?.jobs.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let account = account, let job = jobs?.jobs[indexPath.row]
            else { return }
        let request = UserRequest(requestUrl: job.url, account: account)
        NetworkManager.manager.completeJobInformation(userRequest: request, job: job) { (job, error) in
            //FIXME: Show a message on error
            if error == nil{
                let mirror = Mirror(reflecting: job)
                mirror.children.forEach{ print($0) }
            }
        }
    }
}
