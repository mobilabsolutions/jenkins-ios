//
//  ComputersTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 12.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ComputersTableViewController: UITableViewController {

    var account: Account?
    var computerList: ComputerList?{
        didSet{
            guard let computers = computerList?.computers
                else { return }
            computerData = computers.map({ (computer) -> [(String, String)] in
                return data(for: computer)
            })
        }
    }
    
    private var computerData: [[(String, String)]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performRequest()
    }
    
    private func performRequest(){
        guard let account = account
            else { return }
         NetworkManager.manager.getComputerList(userRequest: UserRequest.userRequestForComputers(account: account)) { (computerList, error) in
            DispatchQueue.main.async {
                
                if let error = error{
                    let alertActions = [
                        UIAlertAction(title: "Done", style: .default, handler: nil)
                    ]
                    self.displayError(title: "Error", message: error.localizedDescription, textFieldConfigurations: [], actions: alertActions)
                }
                self.computerList = computerList
                self.tableView.reloadData()
            }
        }
    }
    
    private func data(for computer: Computer) -> [(String, String)]{
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let gbOfTotalPhysicalMemory = computer.monitorData?.totalPhysicalMemory != nil ?
            "\(numberFormatter.string(from: NSNumber(value: computer.monitorData!.totalPhysicalMemory! / (1024*1024*1024)))!) GB" : "Unknown"
        
        let gbOfAvailablePhysicalMemory = computer.monitorData?.availablePhysicalMemory != nil ?
            "\(numberFormatter.string(from: NSNumber(value: computer.monitorData!.availablePhysicalMemory! / (1024*1024*1024)))!) GB" : "Unknown"
        
        let gbOfTotalSwapMemory = computer.monitorData?.totalSwapSpace != nil ?
            "\(numberFormatter.string(from: NSNumber(value: computer.monitorData!.totalSwapSpace! / (1024*1024*1024)))!) GB" : "Unknown"
        
        let gbOfAvailableSwapMemory = computer.monitorData?.availableSwapSpace != nil ?
            "\(numberFormatter.string(from: NSNumber(value: computer.monitorData!.availableSwapSpace! / (1024*1024*1024)))!) GB" : "Unknown"

        
        return [
            ("Name", computer.displayName),
            ("Executors", "\(computer.numExecutors)"),
            ("Idle", "\(computer.idle)"),
            ("JNLP Agent", "\(computer.jnlpAgent)"),
            ("Offline", "\(computer.offline)"),
            ("Temporarily Offline", "\((computer.temporarilyOffline).textify())"),
            ("Launch Supported", "\(computer.launchSupported)"),
            ("Available Physical Memory", gbOfAvailablePhysicalMemory),
            ("Physical Memory", gbOfTotalPhysicalMemory),
            ("Available Swap Space", gbOfAvailableSwapMemory),
            ("Swap Space", gbOfTotalSwapMemory)
        ]
    }
    
    //MARK: - Tableview data source and delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let computer = computerList?.computers[section]{
            return data(for: computer).count
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return computerList?.computers.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.computerCell, for: indexPath)
        
        cell.textLabel?.text = computerData[indexPath.section][indexPath.row].0
        cell.detailTextLabel?.text = computerData[indexPath.section][indexPath.row].1
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return computerList?.computers[section].displayName
    }
}
