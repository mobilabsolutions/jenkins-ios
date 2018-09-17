//
//  TodayViewController.swift
//  JenkinsiOSTodayExtension
//
//  Created by Robert on 14.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    var favorites: [Favorite] = []
    var favoritables: [[Favoratible]] = [[], []]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        self.tableView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ApplicationUserManager.manager.update()
        
        guard let favorites = DataRetriever.retriever.getSharedApplicationUser()?.favorites
            else { return }
        
        self.favorites = favorites
        // We even want to display the "empty" cells, as in showing that content is loading
        tableView.reloadData()
        requestData()
    }
    
    @nonobjc func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        requestData()
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let maximumCellCount = floor(maxSize.height / tableView.rowHeight)
        let showCellCount = min(maximumCellCount, CGFloat(favorites.count))
        preferredContentSize = CGSize(width: maxSize.width, height: showCellCount * tableView.rowHeight)
    }
    
    func requestData(){
        guard let favorites = DataRetriever.retriever.getSharedApplicationUser()?.favorites
            else { return }
        
        self.favorites = favorites
        favorites.forEach { (favorite) in
            switch favorite.type {
                case .job, .folder:
                    getJob(favorite: favorite)
                case .build:
                    getBuild(favorite: favorite)
            }
        }
    }
    
    private func getJob(favorite: Favorite){
        
        guard let account = favorite.account
            else { return }
        
        let request = UserRequest(requestUrl: favorite.url, account: account)
        _ = NetworkManager.manager.getJob(userRequest: request, completion: { (job, _) in
            if let job = job{
                self.favoritables[0].append(job)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    private func getBuild(favorite: Favorite){
        guard let account = favorite.account
            else { return }
        
        let request = UserRequest(requestUrl: favorite.url, account: account)
        _ = NetworkManager.manager.getBuild(userRequest: request) { (build, _) in
            guard let build = build
                else { return }
            
            self.favoritables[1].append(build)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Tableview data source and delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return favoritables.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? favorites.filter{ $0.type != .build }.count : favorites.filter{ $0.type == .build }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.favoritesCell, for: indexPath) as! FavoriteTableViewCell
        cell.favoritable = favoritables[indexPath.section].count > indexPath.row ? favoritables[indexPath.section][indexPath.row] : nil;
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard favoritables[indexPath.section].count > indexPath.row
            else { return }
        
        let favoritable = favoritables[indexPath.section][indexPath.row]
        
        var components = URLComponents()
        components.scheme = "jenkinsios"
        components.host = "present"
        
        let favoritableType: String
        switch favoritable {
        case is Job:
            favoritableType = (favoritable as! Job).color == .folder ? "Folder" : "Job"
        default:
            favoritableType = "Build"
        }
        
        components.queryItems = [
            URLQueryItem(name: "url", value: favoritable.url.absoluteString),
            URLQueryItem(name: "type", value: favoritableType)
        ]
        
        guard let url = components.url
            else { return }
        
        extensionContext?.open(url, completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
