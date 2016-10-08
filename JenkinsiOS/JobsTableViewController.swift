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
    
    var viewPicker: UIPickerView!
    
    let sections = [Constants.Identifiers.jenkinsCell , Constants.Identifiers.jobCell]
    let jenkinsCells = ["Build Queue", "Jenkins"]
    
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
        viewPicker = UIPickerView()
        viewPicker.dataSource = self
        viewPicker.delegate = self
        viewPicker.backgroundColor = UIColor.clear
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
        let identifier = sections[indexPath.section]
        return prepareCellWithIdentifier(identifier: identifier, indexPath: indexPath)
    }
    
    private func prepareCellWithIdentifier(identifier: String, indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch identifier{
            case Constants.Identifiers.jobCell:
                prepareCellForJob(cell: cell, indexPath: indexPath)
            case Constants.Identifiers.jenkinsCell:
                prepareCellForJenkins(cell: cell, indexPath: indexPath)
            default: return cell
        }
        
        return cell
    }
    
    private func prepareCellForJob(cell: UITableViewCell, indexPath: IndexPath){
        cell.textLabel?.text = currentView?.jobs[indexPath.row].name
        cell.detailTextLabel?.text = currentView?.jobs[indexPath.row].description
        
        if let color = currentView?.jobs[indexPath.row].color{
            cell.imageView?.image = UIImage(named: color.rawValue + "Circle")
        }
    }
    
    private func prepareCellForJenkins(cell: UITableViewCell, indexPath: IndexPath){
        cell.textLabel?.text = jenkinsCells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0: return jenkinsCells.count
            case 1: return currentView?.jobs.count ?? 0
            default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let viewPickerSuperView = UIView()
            
            viewPicker.frame = viewPickerSuperView.bounds
            viewPicker.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            if UIAccessibilityIsReduceTransparencyEnabled() == false{
                
                var effect = UIBlurEffect(style: .light)
                
                let effectView = UIVisualEffectView(effect: effect)
                effectView.frame = viewPicker.bounds
                effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                viewPickerSuperView.addSubview(effectView)
            }
            
            viewPickerSuperView.addSubview(viewPicker)
            
            return viewPickerSuperView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 100 : 0
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
