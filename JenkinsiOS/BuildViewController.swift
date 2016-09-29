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
        
        guard let build = build, let account = account
            else { return }
        
        let userRequest = UserRequest(requestUrl: build.url, account: account)
        
        nameLabel.text = build.displayName ?? "Build #\(build.number)"
        urlLabel.text = "\(build.url)"
        
        let request = URLRequest(url: build.consoleOutputUrl.using(scheme: "https")!)
        print(build.consoleOutputUrl.using(scheme: "https")!)
        consoleWebView.loadRequest(request)
        
        NetworkManager.manager.completeBuildInformation(userRequest: userRequest, build: build) { (build, error) in
            //FIXME: Actually show an alert
            guard error == nil
                else { print(error); return }
            DispatchQueue.main.async {
                //FIXME: Actually present data
                let mirror = Mirror(reflecting: build)
                mirror.children.forEach({ (child) in
                    print("\(child.label.textify()):\((child.value as Optional).textify())")
                })
            }
        }
    }
}

extension BuildViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // We do not want the user to be able to tap any other links
        return navigationType == UIWebViewNavigationType.other
    }
}
