//
//  SettingsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 07.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, AccountProvidable, CurrentAccountProviding, CurrentAccountProvidingDelegate {
    var account: Account? {
        didSet {
            guard let account = account
            else { return }

            updateSections(for: account)
            tableView.reloadData()
        }
    }

    private let remoteConfigManager = RemoteConfigurationManager()

    private var shouldUseDirectAccountDesign: Bool {
        return remoteConfigManager.configuration.shouldUseNewAccountDesign
    }

    var currentAccountDelegate: CurrentAccountProvidingDelegate?

    @IBOutlet var versionLabel: UILabel!

    private enum SettingsSection {
        case plugins
        case users
        case accounts(currentAccountName: String)
        case currentAccount(currentAccountName: String)
        case otherAccounts(otherAccountNames: [String])
        case about

        struct Cell {
            enum CellType {
                case contentCell
                case creationCell
            }

            let actionTitle: String
            let type: CellType
        }

        var title: String {
            switch self {
            case .plugins:
                return "PLUGINS"
            case .users:
                return "USERS"
            case .accounts(currentAccountName: _):
                return "ACCOUNTS"
            case .currentAccount(currentAccountName: _):
                return "ACTIVE ACCOUNT"
            case .otherAccounts(otherAccountNames: _):
                return "OTHER ACCOUNTS"
            case .about:
                return "ABOUT"
            }
        }

        var cells: [Cell] {
            switch self {
            case .plugins:
                return [Cell(actionTitle: "View Plugins", type: .contentCell)]
            case .users:
                return [Cell(actionTitle: "View Users", type: .contentCell)]
            case let .accounts(currentAccountName):
                return [Cell(actionTitle: currentAccountName, type: .contentCell)]
            case let .currentAccount(currentAccountName):
                return [Cell(actionTitle: currentAccountName, type: .contentCell)]
            case let .otherAccounts(otherAccountNames):
                return otherAccountNames.map { Cell(actionTitle: $0, type: .contentCell) }
                    + [Cell(actionTitle: "Add account", type: .creationCell)]
            case .about:
                return [Cell(actionTitle: "Butler", type: .contentCell)]
            }
        }
    }

    private var sections: [SettingsSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Settings"
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CreationTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.Identifiers.creationCell)

        setBottomContentInsetForOlderDevices()
        setVersionNumberText()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Settings"
        tableView.reloadData()

        // Make sure the navigation item does not contain the search bar.
        if #available(iOS 11.0, *) {
            tabBarController?.navigationItem.searchController = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LoggingManager.loggingManager.logSettingsView(accountsIncluded: shouldUseDirectAccountDesign)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizeFooter()
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + sections[section].cells.count
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 47
        }

        return 42
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.headerCell, for: indexPath)
            cell.textLabel?.text = sections[indexPath.section].title
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = Constants.UI.backgroundColor
            cell.textLabel?.backgroundColor = Constants.UI.backgroundColor
            cell.textLabel?.textColor = Constants.UI.skyBlue
            cell.textLabel?.font = UIFont.boldDefaultFont(ofSize: 13)
            return cell
        } else if sections[indexPath.section].cells[indexPath.row - 1].type == .creationCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.creationCell, for: indexPath) as! CreationTableViewCell
            cell.contentView.backgroundColor = .white
            cell.titleLabel.text = sections[indexPath.section].cells[indexPath.row - 1].actionTitle
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.settingsCell, for: indexPath) as! BasicTableViewCell
            cell.contentView.backgroundColor = .white
            cell.title = sections[indexPath.section].cells[indexPath.row - 1].actionTitle
            return cell
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0
        else { return }

        if sections[indexPath.section].cells[indexPath.row - 1].type == .creationCell {
            performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: sections[indexPath.section].cells[indexPath.row - 1])
            return
        }

        switch sections[indexPath.section] {
        case .plugins:
            performSegue(withIdentifier: Constants.Identifiers.showPluginsSegue, sender: nil)
        case .users:
            performSegue(withIdentifier: Constants.Identifiers.showUsersSegue, sender: nil)
        case .accounts:
            performSegue(withIdentifier: Constants.Identifiers.showAccountsSegue, sender: nil)
        case .currentAccount:
            performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: account)
        case .otherAccounts:
            guard let current = account
            else { return }
            let nonCurrent = nonCurrentAccounts(currentAccount: current)
            performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: nonCurrent[indexPath.row - 1])
        case .about:
            performSegue(withIdentifier: Constants.Identifiers.aboutSegue, sender: nil)
        }
    }

    func didChangeCurrentAccount(current: Account) {
        currentAccountDelegate?.didChangeCurrentAccount(current: current)
        account = current

        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let providedAccount = sender as? Account, var dest = segue.destination as? AccountProvidable {
            dest.account = providedAccount
        } else if let cell = sender as? SettingsSection.Cell, cell.type == .creationCell, var dest = segue.destination as? AccountProvidable {
            dest.account = nil
        } else if var dest = segue.destination as? AccountProvidable {
            dest.account = account
        }

        if var dest = segue.destination as? CurrentAccountProviding {
            dest.currentAccountDelegate = self
        }

        if let dest = segue.destination as? AccountDeletionNotifying {
            dest.accountDeletionDelegate = tabBarController as? AccountDeletionNotified
        }

        if let dest = segue.destination as? AddAccountContainerViewController {
            dest.delegate = self
        }

        if let dest = segue.destination as? AddAccountContainerViewController, let account = sender as? Account {
            dest.editingCurrentAccount = account == self.account
        }
    }

    private func updateSections(for account: Account) {
        if shouldUseDirectAccountDesign {
            sections = [
                .plugins, .users,
                .currentAccount(currentAccountName: account.displayName ?? account.baseUrl.absoluteString),
                .otherAccounts(otherAccountNames: nonCurrentAccounts(currentAccount: account).map { $0.displayName ?? $0.baseUrl.absoluteString }),
                .about,
            ]
        } else {
            sections = [
                .plugins, .users,
                .accounts(currentAccountName: account.displayName ?? account.baseUrl.absoluteString),
                .about,
            ]
        }
    }

    private func nonCurrentAccounts(currentAccount account: Account) -> [Account] {
        return AccountManager.manager.accounts.filter { !$0.isEqual(account) }.sorted(by: { (first, second) -> Bool in
            (first.displayName ?? first.baseUrl.absoluteString) < (second.displayName ?? second.baseUrl.absoluteString)
        })
    }

    private func setVersionNumberText() {
        let provider = VersionNumberBuilder()
        versionLabel.text = provider.fullVersionNumberDescription
    }

    private func resizeFooter() {
        guard let footer = tableView.tableFooterView
        else { return }
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let additionalHeight = tabBarHeight + navigationBarHeight + statusBarHeight
        let newMinimumHeight = tableView.frame.height - tableView.visibleCells.reduce(0, { $0 + $1.bounds.height }) - additionalHeight
        footer.frame = CGRect(x: footer.frame.minX, y: footer.frame.minY, width: footer.frame.width,
                              height: max(20, newMinimumHeight))
    }
}

extension SettingsTableViewController: AddAccountTableViewControllerDelegate {
    func didEditAccount(account: Account, oldAccount: Account?, useAsCurrentAccount: Bool) {
        if useAsCurrentAccount {
            self.account = account
            currentAccountDelegate?.didChangeCurrentAccount(current: account)
        }

        var shouldAnimateNavigationStackChanges = true

        if oldAccount == nil {
            let confirmationController = AccountCreatedViewController(nibName: "AccountCreatedViewController", bundle: .main)
            confirmationController.delegate = self
            navigationController?.pushViewController(confirmationController, animated: true)
            shouldAnimateNavigationStackChanges = false
        }

        var viewControllers = navigationController?.viewControllers ?? []
        // Remove the add account view controller from the navigation controller stack
        viewControllers = viewControllers.filter { !($0 is AddAccountContainerViewController) }
        navigationController?.setViewControllers(viewControllers, animated: shouldAnimateNavigationStackChanges)

        if let currentAccount = self.account {
            updateSections(for: currentAccount)
        }
        tableView.reloadData()
    }

    func didDeleteAccount(account: Account) {
        if account == self.account {
            self.account = AccountManager.manager.accounts.first
        }

        if let currentAccount = self.account {
            updateSections(for: currentAccount)
        }
        tableView.reloadData()
        navigationController?.popViewController(animated: false)

        let handler = OnBoardingHandler()
        if AccountManager.manager.accounts.isEmpty && handler.shouldShowAccountCreationViewController() {
            let navigationController = UINavigationController()
            present(navigationController, animated: false, completion: nil)
            handler.showAccountCreationViewController(on: navigationController, delegate: self)
        }
    }
}

extension SettingsTableViewController: AccountCreatedViewControllerDelegate {
    func doneButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsTableViewController: OnBoardingDelegate {
    func didFinishOnboarding(didAddAccount _: Bool) {
        account = AccountManager.manager.currentAccount ?? AccountManager.manager.accounts.first
        dismiss(animated: true, completion: nil)
    }
}
