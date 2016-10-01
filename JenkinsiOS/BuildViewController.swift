//
//  BuildViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildViewController: UIViewController {

    var build: Build?
    var account: Account?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var consoleWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        consoleWebView.allowsLinkPreview = true
        consoleWebView.delegate = self
        
        updateUI()
        
        guard let build = build
            else { return }
        
        let request = URLRequest(url: build.consoleOutputUrl.using(scheme: "https")!)
        consoleWebView.loadRequest(request)
        
        if build.isFullVersion == false, let account = account{
            let userRequest = UserRequest(requestUrl: build.url, account: account)
            
            NetworkManager.manager.completeBuildInformation(userRequest: userRequest, build: build, completion: { (_, error) in
                //FIXME: Actually display errors
                DispatchQueue.main.async {
                    self.updateUI()
                }
            })
        }
    }
    
    func updateUI(){
        guard let build = build
            else { return }
        
        nameLabel.text = build.fullDisplayName ?? build.displayName ?? "Build #\(build.number)"
        urlLabel.text = "\(build.url)"
    }
}

extension BuildViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // We do not want the user to be able to tap any other links
        return navigationType == UIWebViewNavigationType.other
    }
}
