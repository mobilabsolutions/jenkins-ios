//
//  ChangesTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 26.02.19.
//  Copyright © 2019 MobiLab Solutions. All rights reserved.
//

import UIKit

class ChangesTableViewController: UITableViewController, AccountProvidable {
    var build: Build?
    var account: Account?

    private var items: [Item] {
        return build?.allChangeItems ?? []
    }

    private enum CellType: Int {
        case commitId = 0
        case author
        case date
        case message

        var cellStyle: CellStyle {
            switch self {
            case .commitId: return .header
            default: return .basic
            }
        }

        var title: String? {
            switch self {
            case .commitId: return nil
            case .author: return "Author"
            case .date: return "Date"
            case .message: return "Message"
            }
        }

        var cornersToRound: UIRectCorner? {
            switch self {
            case .commitId: return [.topLeft, .topRight]
            case .author: return nil
            case .date: return nil
            case .message: return [.bottomLeft, .bottomRight]
            }
        }

        func content(from item: Item) -> String? {
            switch self {
            case .commitId: return item.commitId
            case .author: return item.author?.fullName ?? "Unknown author"
            case .date: return item.date ?? "Unknown date"
            case .message: return item.message ?? "No message"
            }
        }
    }

    private enum CellStyle {
        case basic
        case header
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        title = "Changes"
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return items.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 4
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = CellType(rawValue: indexPath.row)
        else { fatalError("No cell type for index path \(indexPath)") }

        switch cellType.cellStyle {
        case .basic: return createBasicCell(for: indexPath, cellType: cellType, item: items[indexPath.section])
        case .header: return createHeaderCell(for: indexPath, cellType: cellType, item: items[indexPath.section])
        }
    }

    private func createHeaderCell(for indexPath: IndexPath, cellType: CellType, item: Item) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.headerCell, for: indexPath) as? CorneredBasicTableViewCell
        else { fatalError("Could not dequeue header cell of correct type for changes view controller") }
        cell.titleLabel.text = cellType.content(from: item)
        cell.container?.backgroundColor = Constants.UI.veryLightBlue.withAlphaComponent(0.08)
        cell.contentView.backgroundColor = tableView.backgroundColor
        if let cornersToRound = cellType.cornersToRound {
            cell.container.cornersToRound = cornersToRound
        }

        cell.container.borders = [.bottom, .left, .right, .top]
        return cell
    }

    private func createBasicCell(for indexPath: IndexPath, cellType: CellType, item: Item) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.detailContentCell, for: indexPath) as? DetailTableViewCell
        else { fatalError("Could not dequeue content cell of correct type for changes view controller") }

        cell.detailLabel.text = cellType.content(from: item)
        cell.titleLabel.text = cellType.title

        if let cornersToRound = cellType.cornersToRound {
            cell.container.cornersToRound = cornersToRound
        }

        cell.container.borders = [.bottom, .left, .right]

        return cell
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 8
    }

    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tableView.backgroundColor
        return view
    }

    override func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
        return nil
    }
}
