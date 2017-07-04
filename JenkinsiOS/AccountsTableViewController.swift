//
//  AccountsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AccountsTableViewController: BaseTableViewController {
    
    private let headers = ["Favorites", "Accounts"]
    
    private var hasFavorites: Bool {
        return ApplicationUserManager.manager.applicationUser.favorites.isEmpty == false
    }
    
    private var hasAccounts: Bool{
        return AccountManager.manager.accounts.isEmpty == false
    }
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        navigationItem.leftBarButtonItem = editButtonItem
        registerForPreviewing(with: self, sourceView: tableView)
        
        emptyTableViewText = "No accounts have been created yet.\nTo create an account, tap on the + below"
        emptyTableViewImages = [ UIImage(named: "plus")! ]
        
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddAccountViewController)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    //MARK: - View controller navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath, let dest = segue.destination as? JobsTableViewController, segue.identifier == Constants.Identifiers.showJobsSegue{
            prepare(viewController: dest, indexPath: indexPath)
        }
        else if segue.identifier == Constants.Identifiers.editAccountSegue, let dest = segue.destination as? AddAccountTableViewController, let indexPath = sender as? IndexPath{
            prepare(viewController: dest, indexPath: indexPath)
        }
        else if segue.identifier == Constants.Identifiers.showBuildSegue || segue.identifier == Constants.Identifiers.showJobSegue,
                let favoritableAndFavorite = sender as? (Favoratible, Favorite){
            prepare(favoritableViewController: segue.destination, for: favoritableAndFavorite)
        }
        navigationController?.isToolbarHidden = true
    }
    
    fileprivate func prepare(viewController: UIViewController, indexPath: IndexPath){
        if let addAccountViewController = viewController as? AddAccountTableViewController{
            addAccountViewController.account = AccountManager.manager.accounts[indexPath.row]
        }
        else if let jobsViewController = viewController as? JobsTableViewController{
            jobsViewController.account = AccountManager.manager.accounts[indexPath.row]
        }
    }

    fileprivate func prepare(favoritableViewController: UIViewController, for favoritableAndFavorite: (Favoratible, Favorite)){
        if let jobViewController = favoritableViewController as? JobViewController, let job = favoritableAndFavorite.0 as? Job{
            jobViewController.account = favoritableAndFavorite.1.account
            jobViewController.job = job
        }
        else if let buildViewController = favoritableViewController as? BuildViewController, let build = favoritableAndFavorite.0 as? Build{
            buildViewController.account = favoritableAndFavorite.1.account
            buildViewController.build = build
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        tableView.reloadData()
    }
    
    @IBAction func showInformationViewController(){
        performSegue(withIdentifier: Constants.Identifiers.showInformationSegue, sender: nil)
    }
    
    func showAddAccountViewController(){
        performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: nil)
    }
    
    //MARK: - Tableview datasource and delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.accountCell, for: indexPath) as! AccountTableViewCell
            
            let urlString = "\(AccountManager.manager.accounts[indexPath.row].baseUrl)"
            
            cell.accountNameLabel.text = AccountManager.manager.accounts[indexPath.row].displayName ?? urlString
            cell.urlLabel.text = urlString
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.favoritesCell, for: indexPath)
            
            if let favoritesCell = cell as? AllFavoritesTableViewCell {
                if favoritesCell.loader == nil{
                    favoritesCell.loader = FavoritesLoader(with: favoritesCell)
                }
                favoritesCell.favorites = ApplicationUserManager.manager.applicationUser.favorites
                favoritesCell.delegate = self
            }

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : AccountManager.manager.accounts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 1
            else { return }
        
        if isEditing{
            performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: indexPath)
        }
        else{
            performSegue(withIdentifier: Constants.Identifiers.showJobsSegue, sender: indexPath)
        }
    }
    
    override func numberOfSections() -> Int {
        return headers.count
    }
    
    override func tableViewIsEmpty() -> Bool {
        return AccountManager.manager.accounts.count == 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < headers.count ? headers[section] : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && !hasFavorites && !hasAccounts) || (section == 1 && !hasAccounts) {
            return 0
        }
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && !hasFavorites && !hasAccounts{
            return 0
        }
        else if indexPath.section == 0 && !hasFavorites && hasAccounts {
            return 75
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { (_, indexPath) in
                do{
                    try AccountManager.manager.deleteAccount(account: AccountManager.manager.accounts[indexPath.row])
                    self.tableView.reloadData()
                }
                catch{
                    self.displayError(title: "Error", message: "Something went wrong", textFieldConfigurations: [], actions: [
                            UIAlertAction(title: "Alright", style: .cancel, handler: nil)
                        ])
                    self.tableView.reloadData()
                }
            }),
            UITableViewRowAction(style: .normal, title: "Edit", handler: { (_, indexPath) in
                self.performSegue(withIdentifier: Constants.Identifiers.editAccountSegue, sender: indexPath)
            })
        ]
    }
}

extension AccountsTableViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Ugly hack to ensure that a presented popover will not be presented once pushed
        viewControllerToCommit.dismiss(animated: true, completion: nil)
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location)
            else { return nil }

        switch indexPath.section{
            case 0:
                guard let cell = tableView.cellForRow(at: indexPath) as? AllFavoritesTableViewCell
                        else { return nil }
                let translatedPoint = cell.collectionView.convert(location, from: view)
                guard let collectionViewCellIndexPath = cell.collectionView.indexPathForItem(at: translatedPoint)
                        else { return nil }
                guard let favoritableAndFavorite = cell.getFavoritableAndFavoriteForIndexPath(indexPath: collectionViewCellIndexPath)
                        else { return nil }

                if let collectionViewCellFrame = cell.collectionView.layoutAttributesForItem(at: collectionViewCellIndexPath)?.frame {
                    previewingContext.sourceRect = cell.collectionView.convert(collectionViewCellFrame, to: self.view)
                }

                return getFavoritableViewController(for: favoritableAndFavorite)
            case 1:
                guard isEditing == false
                        else { return nil }
                previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
                return getJobsViewController(for: indexPath)
            default: return nil
        }
    }

    private func getFavoritableViewController(for favoritableAndFavorite: (favoritable: Favoratible, favorite: Favorite)) -> UIViewController?{

        var viewController: UIViewController?

        switch favoritableAndFavorite.favorite.type{
            case .build:
                viewController = (UIApplication.shared.delegate as? AppDelegate)?.getViewController(name: "BuildViewController")
            case .job:
                viewController = (UIApplication.shared.delegate as? AppDelegate)?.getViewController(name: "JobViewController")
        }

        guard let favoritableViewController = viewController
              else { return nil }

        prepare(favoritableViewController: favoritableViewController, for: favoritableAndFavorite)
        return favoritableViewController
    }

    private func getJobsViewController(for indexPath: IndexPath) -> UIViewController?{
        guard let jobsViewController = (UIApplication.shared.delegate as? AppDelegate)?.getViewController(name: "JobsTableViewController")
                else { return nil }
        prepare(viewController: jobsViewController, indexPath: indexPath)

        return jobsViewController
    }
}

extension AccountsTableViewController: AllFavoritesTableViewCellDelegate{
    func didSelectErroredFavorite(favorite: Favorite) {
        UIApplication.shared.openURL(favorite.url)
    }

    func didSelectLoadedFavoritable(favoritable: Favoratible, for favorite: Favorite) {
        switch favorite.type{
            case .build:
                performSegue(withIdentifier: Constants.Identifiers.showBuildSegue, sender: (favoritable, favorite))
            case .job:
                performSegue(withIdentifier: Constants.Identifiers.showJobSegue, sender: (favoritable, favorite))
        }
    }
}
