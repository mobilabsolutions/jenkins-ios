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

    private var artifacts: [Artifact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Artifacts"
        
        guard let build = build
            else { return }
        
        self.artifacts = build.artifacts
    }

    private func downloadArtifact(artifact: Artifact, completion: @escaping (Data?) -> ()){
        guard let account = account
            else { return }
        NetworkManager.manager.downloadArtifact(artifact: artifact, account: account) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil
                    else {
                        self.displayNetworkError(error: error!, onReturnWithTextFields: { (dict) in
                            guard let username = dict["username"], let password = dict["password"]
                                else { return }
                            self.account?.username = username
                            self.account?.password = password
                            
                            self.downloadArtifact(artifact: artifact, completion: completion)
                        })
                        return
                }
                
                completion(data)
            }
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artifacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.artifactsCell, for: indexPath)

        cell.textLabel?.text = artifacts[indexPath.row].filename
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        downloadArtifact(artifact: artifacts[indexPath.row]) { (data) in
            guard let data = data
                else { return }
            let composer = MFMailComposeViewController()
            
            var subject = "Artifact \(self.artifacts[indexPath.row].filename)"
            if let build = self.build{
                subject += " from Build \(build.fullDisplayName ?? build.displayName ?? "#\(build.number)")"
            }
            composer.setSubject(subject)
            composer.setMessageBody("Sent using Jenkins iOS", isHTML: false)
            composer.addAttachmentData(data, mimeType: "", fileName: self.artifacts[indexPath.row].filename)
            
            composer.mailComposeDelegate = self
            
            self.present(composer, animated: true, completion: nil)
        }
    }
}

extension ArtifactsTableViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
