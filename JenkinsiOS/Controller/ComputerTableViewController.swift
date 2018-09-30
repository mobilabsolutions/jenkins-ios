//
//  ComputerTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 10.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class ComputerTableViewController: UITableViewController {
    var computer: Computer? {
        didSet {
            computerData = computer != nil ? data(for: computer!) : []
        }
    }

    private var computerData: [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.computerCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Identifiers.headerCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = Constants.UI.backgroundColor
        title = computer?.displayName ?? "Node"
    }

    private func data(for computer: Computer) -> [(String, String)] {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let gbOfTotalPhysicalMemory = computer.monitorData?.totalPhysicalMemory?.bytesToGigabytesString(numberFormatter: numberFormatter) ?? "Unknown"
        let gbOfAvailablePhysicalMemory = computer.monitorData?.availablePhysicalMemory?.bytesToGigabytesString(numberFormatter: numberFormatter) ?? "Unknown"
        let gbOfTotalSwapMemory = computer.monitorData?.totalSwapSpace?.bytesToGigabytesString(numberFormatter: numberFormatter) ?? "Unknown"
        let gbOfAvailableSwapMemory = computer.monitorData?.availableSwapSpace?.bytesToGigabytesString(numberFormatter: numberFormatter) ?? "Unknown"

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
            ("Swap Space", gbOfTotalSwapMemory),
        ]
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return computerData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.headerCell, for: indexPath)
            cell.textLabel?.text = computer?.displayName.uppercased() ?? "NODE"
            cell.contentView.backgroundColor = Constants.UI.backgroundColor
            cell.textLabel?.textColor = Constants.UI.greyBlue
            cell.textLabel?.font = UIFont.boldDefaultFont(ofSize: 13)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.computerCell, for: indexPath) as! DetailTableViewCell
        cell.titleLabel.text = computerData[indexPath.row].0
        cell.detailLabel.text = computerData[indexPath.row].1
        cell.container.borders = [.left, .right, .bottom]

        if indexPath.row == 0 {
            cell.container.cornersToRound = [.topLeft, .topRight]
            cell.container.borders.insert(.top)
        } else if indexPath.row == computerData.count - 1 {
            cell.container.cornersToRound = [.bottomLeft, .bottomRight]
        }

        return cell
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        guard let cell = cell as? DetailTableViewCell
        else { return }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }

    override func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
        return nil
    }
}
