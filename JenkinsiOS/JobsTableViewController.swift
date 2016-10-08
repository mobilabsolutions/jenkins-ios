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
    var currentView: View?
    
    @IBOutlet weak var viewPicker: UIPickerView!
    
    override func viewDidLoad() {
        loadJobs()
        setUpPicker()
    }
    
    /// Load the jobs from the remote server
    func loadJobs(){
        guard let account = account
            else { return }

        NetworkManager.manager.getJobs(userRequest: UserRequest.userRequestForJobList(account: account)) { (jobList, error) in
            //FIXME: Display an error message on error
            if error == nil && jobList != nil{
                self.jobs = jobList
                self.currentView = jobList!.allJobsView
                
                DispatchQueue.main.async {
                    self.viewPicker.reloadAllComponents()
                    self.pickerScrollToAllView()
                    self.tableView.reloadData()
                }
                
            }
            else{
                print("Error: \(error)")
            }
        }
    }
    
    func setUpPicker(){
        viewPicker.dataSource = self
        viewPicker.delegate = self
    }
    
    
    private func pickerScrollToAllView(){
        if let jobs = jobs, let currentView = currentView, let index = jobs.views.index(where: {$0.name == currentView.name}){
            viewPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    //MARK: - Viewcontroller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? JobViewController, segue.identifier == Constants.Identifiers.showJobSegue, let jobCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: jobCell), let job = currentView?.jobs[indexPath.row]{
            dest.job = job
            dest.account = account
        }
    }
    
    //MARK: - Tableview datasource and delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.jobCell, for: indexPath)
        
        cell.textLabel?.text = currentView?.jobs[indexPath.row].name
        cell.detailTextLabel?.text = currentView?.jobs[indexPath.row].color?.rawValue ?? currentView?.jobs[indexPath.row].description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentView?.jobs.count ?? 0
    }
}

extension JobsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return jobs?.views.count ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return jobs?.views[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentView = jobs?.views[row]
        tableView.reloadData()
    }
}
