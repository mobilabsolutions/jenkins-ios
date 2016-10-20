//
//  ConsoleOutputViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ConsoleOutputViewController: UIViewController {

    @IBOutlet weak var consoleWebView: UIWebView!
    var request: URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        consoleWebView.allowsLinkPreview = true
        consoleWebView.delegate = self
        
        guard let request = request
            else { return }
        
        consoleWebView.loadRequest(request)
    }
}

//MARK: - Webview delegate
extension ConsoleOutputViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // We do not want the user to be able to tap any other links
        return navigationType == UIWebViewNavigationType.other
    }
}
