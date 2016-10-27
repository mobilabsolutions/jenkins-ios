//
//  JobsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class JobsTableViewController: RefreshingTableViewController{
    
    var account: Account?
    var jobs: JobList?
    var currentView: View?
    
    var viewPicker: UIPickerView!
    private var searchController: UISearchController?
    
    let sections = [Constants.Identifiers.jenkinsCell , Constants.Identifiers.jobCell]
    let jenkinsCellSegues = [("Build Queue", Constants.Identifiers.showBuildQueueSegue), ("Jenkins", Constants.Identifiers.showJenkinsSegue)]
    
    //MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJobs()
        setUpPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController?.searchBar.text = ""
    }
    
    override func refresh(){
        loadJobs()
    }

    //MARK: - Data loading and displaying
    /// Load the jobs from the remote server
    @objc private func loadJobs(){
        guard let account = account
            else { return }
        
        NetworkManager.manager.getJobs(userRequest: UserRequest.userRequestForJobList(account: account)) { (jobList, error) in            
            guard jobList != nil && error == nil
                else {
                    if let error = error{
                        self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!
                            
                            self.loadJobs()
                        })
                    }
                    
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                    }
                    
                    return
            }
            
            self.jobs = jobList
            self.currentView = jobList!.allJobsView
            
            DispatchQueue.main.async {
                self.viewPicker.reloadAllComponents()
                self.pickerScrollToAllView()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.setupSearchController()
            }
        }
    }
    
    private func setupSearchController(){
        let searchResultsController = SearchResultsTableViewController(searchData: jobs?.allJobsView?.jobs.map({ (job) -> Searchable in
            return Searchable(searchString: job.name, data: job, action: {
                self.searchController?.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: job)
            })
        }) ?? [])
        searchResultsController.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController?.searchResultsUpdater = searchResultsController.searcher
        tableView.tableHeaderView = searchController?.searchBar
        tableView.contentOffset.y += tableView.tableHeaderView?.frame.height ?? 0
    }
    
    private func setUpPicker(){
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
        else if let dest = segue.destination as? JobViewController, segue.identifier == Constants.Identifiers.showJobSegue, let job = sender as? Job{
            dest.job = job
            dest.account = account
        }
        else if let dest = segue.destination as? BuildQueueTableViewController, segue.identifier == Constants.Identifiers.showBuildQueueSegue{
            dest.account = account
        }
        else if let dest = segue.destination as? JenkinsInformationTableViewController, segue.identifier == Constants.Identifiers.showJenkinsSegue{
            dest.account = account
        }
    }
    
    //MARK: - Tableview datasource and delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            performSegue(withIdentifier: jenkinsCellSegues[indexPath.row].1, sender: nil)
        }
    }
    
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
        guard let job = currentView?.jobs[indexPath.row]
            else { return }
        prepare(cell: cell, for: job)
    }
    
    fileprivate func prepare(cell: UITableViewCell, for job: Job){
        cell.textLabel?.text = job.name
        cell.detailTextLabel?.text = job.description
        
        if let color = job.color{
            cell.imageView?.image = UIImage(named: color.rawValue + "Circle")
        }
    }
    
    private func prepareCellForJenkins(cell: UITableViewCell, indexPath: IndexPath){
        cell.textLabel?.text = jenkinsCellSegues[indexPath.row].0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0: return jenkinsCellSegues.count
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
                
                let effect = UIBlurEffect(style: .light)
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

extension JobsTableViewController: SearchResultsControllerDelegate{
    func setup(cell: UITableViewCell, for searchable: Searchable) {
        guard let job = searchable.data as? Job
            else { return }
        prepare(cell: cell, for: job)
    }
}
