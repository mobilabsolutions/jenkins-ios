//
//  PluginTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 17.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class PluginTableViewController: UITableViewController {
    var plugin: Plugin?
    var allPlugins: [Plugin] = []

    private var sections: [PluginTableViewControllerSection] = []
    private var pluginData: [(name: String, value: String)] = []
    private var dependencyData: [(name: String, indexInAllPlugins: Array<Plugin>.Index?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = Constants.UI.backgroundColor

        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.pluginCell)

        setupData()
    }

    private func setupData() {
        guard let plugin = plugin
        else { sections = []; pluginData = []; return }

        sections = plugin.dependencies.isEmpty ? [.pluginHeader, .pluginData] : [
            .pluginHeader, .pluginData,
            .dependencyHeader, .dependencyData,
        ]
        pluginData = [
            (name: "Name", value: plugin.longName ?? plugin.shortName),
            (name: "Active", value: "\(plugin.active)"),
            (name: "Has Update", value: plugin.hasUpdate.textify()),
            (name: "Enabled", value: plugin.enabled.textify()),
            (name: "Version", value: plugin.version.textify()),
            (name: "Supports Dynamic Load", value: plugin.supportsDynamicLoad.textify()),
        ]

        dependencyData = plugin.dependencies.map { (name: $0.shortName, indexInAllPlugins: self.index(of: $0)) }
    }

    private func index(of dependency: Dependency) -> Array<Plugin>.Index? {
        return allPlugins.index(where: { $0.shortName == dependency.shortName })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PluginTableViewController, let plugin = sender as? Plugin {
            dest.plugin = plugin
            dest.allPlugins = allPlugins
        }
    }

    // MARK: - Table view data source

    private enum PluginTableViewControllerSection: Int {
        case pluginHeader = 0
        case pluginData
        case dependencyHeader
        case dependencyData
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = PluginTableViewControllerSection(rawValue: section)
        else { return 0 }

        switch section {
        case .pluginHeader:
            return 1
        case .pluginData:
            return pluginData.count
        case .dependencyHeader:
            return 1
        case .dependencyData:
            return plugin?.dependencies.count ?? 0
        }
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = PluginTableViewControllerSection(rawValue: indexPath.section)
        else { return UITableViewCell() }

        switch section {
        case .pluginHeader:
            return headerCell(for: indexPath, title: (plugin?.longName ?? plugin?.shortName ?? "").uppercased())
        case .dependencyHeader:
            return headerCell(for: indexPath, title: "DEPENDENCIES")
        case .pluginData:
            return pluginDataCell(for: indexPath)
        case .dependencyData:
            return dependencyDataCell(for: indexPath)
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = PluginTableViewControllerSection(rawValue: indexPath.section), section == .dependencyData,
            let index = dependencyData[indexPath.row].indexInAllPlugins
        else { return }

        performSegue(withIdentifier: Constants.Identifiers.showPluginSegue, sender: allPlugins[index])
    }

    private func pluginDataCell(for indexPath: IndexPath) -> DetailTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.pluginCell, for: indexPath) as! DetailTableViewCell
        cell.titleLabel.text = pluginData[indexPath.row].name
        cell.detailLabel.text = pluginData[indexPath.row].value
        cell.container.borders = [.left, .right, .bottom]
        cell.container.cornersToRound = []
        cell.selectionStyle = .none

        if indexPath.row == 0 {
            cell.container.borders.insert(.top)
            cell.container.cornersToRound = [.topLeft, .topRight]
        } else if indexPath.row == pluginData.count - 1 {
            cell.container.cornersToRound = [.bottomLeft, .bottomRight]
        }

        return cell
    }

    private func dependencyDataCell(for indexPath: IndexPath) -> BasicTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.dependencyDataCell, for: indexPath) as! BasicTableViewCell

        cell.nextImageType = dependencyData[indexPath.row].indexInAllPlugins != nil ? .next : .none
        cell.title = dependencyData[indexPath.row].name
        cell.containerView?.backgroundColor = Constants.UI.backgroundColor

        return cell
    }

    private func headerCell(for indexPath: IndexPath, title: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.headerCell, for: indexPath)
        cell.textLabel?.text = title
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = PluginTableViewControllerSection(rawValue: indexPath.section)
        else { return 0 }

        switch section {
        case .pluginHeader: fallthrough
        case .dependencyHeader: return 38
        case .dependencyData: fallthrough
        case .pluginData: return 51
        }
    }
}
