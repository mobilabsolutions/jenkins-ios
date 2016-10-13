//
//  BuildsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildsTableViewController: UITableViewController {

    var builds: [Build]?
    var specialBuilds: [(String, Build)] = []
    
    var account: Account?
    
    override func viewDidLoad() {
        completeAllBuilds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        completeAllBuilds()
    }
    
    private func completeAllBuilds(){
        completeBuilds(builds: specialBuilds.map({ $0.1 }), section: 0)
        if let builds = builds{
            completeBuilds(builds: builds, section: 1)
        }
    }
    
    private func completeBuilds(builds: [Build], section: Int){
        if let account = account{
            for (index, build) in builds.enumerated().filter({$0.1.isFullVersion == false}){
                let userRequest = UserRequest(requestUrl: build.url, account: account)
                NetworkManager.manager.completeBuildInformation(userRequest: userRequest, build: build, completion: { (build, error) in
                    //FIXME: Display errors
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
                    }
                })
            }
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0: return specialBuilds.count
            case 1: return builds?.count ?? 0
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
            case 0: return "Special builds"
            case 1: return "All builds"
            default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.buildCell, for: indexPath)
        
        var build: Build!
        
        if indexPath.section == 0{
            build = specialBuilds[indexPath.row].1
            cell.textLabel?.text = specialBuilds[indexPath.row].0 + " (#\(build.number))"
        }
        else if indexPath.section == 1{
            build = builds![indexPath.row]
            cell.textLabel?.text = build.fullDisplayName ?? "#\(build.number)"
        }
        
        if let result = build?.result?.lowercased(){
            cell.imageView?.image = UIImage(named: "\(result)Circle")
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = sender as? UITableViewCell, let dest = segue.destination as? BuildViewController, segue.identifier == Constants.Identifiers.showBuildSegue, let indexPath = tableView.indexPath(for: s){
            if indexPath.section == 1{
                dest.build = builds?[indexPath.row]
            }
            else{
                dest.build = specialBuilds[indexPath.row].1
            }
            dest.account = account
        }
    }

}
