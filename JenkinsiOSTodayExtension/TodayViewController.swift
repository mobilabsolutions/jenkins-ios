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
        
        tableView.rowHeight = 50
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
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
            if favorite.type == .job{
                getJob(favorite: favorite)
            }
            else if favorite.type == .build{
                getBuild(favorite: favorite)
            }
        }
    }
    
    private func getJob(favorite: Favorite){
        
        guard let account = favorite.account, favorite.type == .job
            else { return }
        
        let request = UserRequest(requestUrl: favorite.url, account: account)
        NetworkManager.manager.getJob(userRequest: request, completion: { (job, _) in
            if let job = job{
                self.favoritables[0].append(job)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    private func getBuild(favorite: Favorite){
        guard let account = favorite.account, favorite.type == .build
            else { return }
        
        let request = UserRequest(requestUrl: favorite.url, account: account)
        NetworkManager.manager.getBuild(userRequest: request) { (build, _) in
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
        return section == 0 ? favorites.filter{ $0.type == .job }.count : favorites.filter{ $0.type == .build }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.favoritesCell, for: indexPath)

        guard favoritables[indexPath.section].count > indexPath.row
            else {
                cell.textLabel?.text = "Loading..."
                cell.detailTextLabel?.text = "Loading \(indexPath.section == 0 ? "Job" : "Build")"
                cell.imageView?.image = UIImage(named: "emptyCircle")
                cell.selectionStyle = .none
                
                return cell
        }
        
        if let job = favoritables[indexPath.section][indexPath.row] as? Job{
            cell.textLabel?.text = job.name
            cell.detailTextLabel?.text = job.healthReport.first?.description
            
            if let color = job.color?.rawValue{
                cell.imageView?.image = UIImage(named: color + "Circle")
            }
        }
        else if let build = favoritables[indexPath.section][indexPath.row] as? Build{
            cell.textLabel?.text = build.fullDisplayName ?? build.displayName ?? "Build #\(build.number)"
            
            if let duration = build.duration{
                cell.detailTextLabel?.text = build.duration != nil ? "Duration: \(duration.toString())" : nil
            }
            
            print(build.result)
            
            if let result = build.result?.lowercased(){
                cell.imageView?.image = UIImage(named: result + "Circle")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard favoritables[indexPath.section].count > indexPath.row
            else { return }
        
        let favoritable = favoritables[indexPath.section][indexPath.row]
        
        var components = URLComponents()
        components.scheme = "jenkinsios"
        components.host = "present"
        components.queryItems = [
            URLQueryItem(name: "url", value: favoritable.url.absoluteString),
            URLQueryItem(name: "type", value: (favoritable is Job) ? "Job" : "Build")
        ]
        
        guard let url = components.url
            else { return }
        
        extensionContext?.open(url, completionHandler: nil)
    }
}
