//
//  ArtifactsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 19.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import MessageUI

class ArtifactsTableViewController: UITableViewController {

    var account: Account?
    var build: Build?

    private let firstRowHeight: CGFloat = 40.0
    private let generalRowHeight: CGFloat = 30.0
    
    private var currentDownloadTask: URLSessionTaskController?
    private var artifacts: [Artifact] = []
    
    private var numberFormatter = NumberFormatter()
    
    @IBOutlet weak var topContainer: CorneredView!
    @IBOutlet weak var bottomContainer: CorneredView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Artifact List"
        
        numberFormatter.numberStyle = .decimal
        
        tableView.backgroundColor = Constants.UI.backgroundColor
        topContainer.layer.borderWidth = 1
        topContainer.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        topContainer.cornersToRound = [.topRight, .topLeft]
        bottomContainer.cornersToRound = [.bottomLeft, .bottomRight]
        bottomContainer.borders = [.bottom, .left, .right]
        resizeBottomContainer()
        
        guard let build = build
            else { return }
        
        self.artifacts = build.artifacts
        updateArtifactSizes()
    }
    
    override func viewWillLayoutSubviews() {
        resizeBottomContainer()
        super.viewWillLayoutSubviews()
    }
    
    fileprivate func resizeBottomContainer() {
        
        guard let superView = bottomContainer.superview, let topSuperView = topContainer.superview
            else { return }
        
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let bottomSpacing: CGFloat = 50
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let newHeight = tableView.frame.height - topSuperView.frame.height - firstRowHeight - generalRowHeight * CGFloat(artifacts.count - 1) - bottomSpacing - navigationBarHeight - statusBarHeight
        
        let minimumHeight: CGFloat = 10.0
        superView.frame = CGRect(origin: superView.frame.origin, size: CGSize(width: superView.frame.width, height: max(newHeight, minimumHeight)))
        superView.setNeedsLayout()
    }
    
    private func updateArtifactSizes(){
        self.artifacts.forEach { (artifact) in
            guard let account = self.account
                else { return }
            _ = NetworkManager.manager.setSizeForArtifact(artifact: artifact, account: account){
                _, _ in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func downloadArtifact(artifact: Artifact, completion: @escaping (Data?) -> ()){
        guard let account = account
            else { return }
        self.currentDownloadTask = NetworkManager.manager.downloadArtifact(artifact: artifact, account: account) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil
                    else {
                        self.showErrorMessage(for: error!, with: artifact, completion: completion)
                        return
                }
                self.dismiss(animated: true, completion: { 
                    completion(data)
                })
            }
        }
    }
    
    private func showErrorMessage(for error: Error, with artifact: Artifact, completion: @escaping (Data?) -> ()){
        self.displayNetworkError(error: error, onReturnWithTextFields: { (dict) in
            guard let username = dict["username"], let password = dict["password"]
                else { return }
            self.account?.username = username
            self.account?.password = password
            
            self.downloadArtifact(artifact: artifact, completion: completion)
        })

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artifacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.artifactsCell, for: indexPath) as! ArtifactTableViewCell
        cell.artifactName.text = "\(artifacts[indexPath.row].filename) (\(artifacts[indexPath.row].size?.bytesToGigabytesString(numberFormatter: numberFormatter) ?? "? B"))"
        cell.container.borders = [.left, .right]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showModalInformationViewController()
        
        let artifact = artifacts[indexPath.row]
        
        downloadArtifact(artifact: artifact) { [unowned self] (data) in
            guard let data = data
                else { return }
            self.shareArtifact(data: data, artifact: artifact)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? firstRowHeight : generalRowHeight
    }
    
    private func shareArtifact(data: Data, artifact: Artifact) {
        let url: URL
        if #available(iOS 10.0, *) {
            url = FileManager.default.temporaryDirectory.appendingPathComponent(artifact.filename)
        } else {
            url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(artifact.filename)
        }
        
        do {
            try data.write(to: url)
        } catch {
            self.displayError(title: "Error", message: "Could not save file",
                              textFieldConfigurations: [],
                              actions: [UIAlertAction(title: "Done", style: UIAlertActionStyle.cancel, handler: nil)])
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    private func showModalInformationViewController(){
        let modalInfoViewController = ModalInformationViewController.withLoadingIndicator(title: "Loading Artifact...")
        modalInfoViewController.delegate = self
        if self.presentedViewController == nil && navigationController?.presentedViewController == nil{
            navigationController?.present(modalInfoViewController, animated: true, completion: nil)
        }
    }
        
    fileprivate func dismissDownload(){
        currentDownloadTask?.cancelTask()
    }
}

extension ArtifactsTableViewController: ModalInformationViewControllerDelegate{
    func didDismiss() {
        self.dismissDownload()
    }
}
