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
        
        reload()
    }
    
    func addIndicatorView(){
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    func replaceIndicatorViewWithReload(){
        if let activityIndicator = navigationItem.rightBarButtonItem?.customView as? UIActivityIndicatorView{
            activityIndicator.stopAnimating()
        }
        let reloadButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        navigationItem.rightBarButtonItem = reloadButtonItem
    }
    
    func reload(){
        guard let request = request
            else { return }
        
        addIndicatorView()
        consoleWebView.loadRequest(request)
    }
}

//MARK: - Webview delegate
extension ConsoleOutputViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // We do not want the user to be able to tap any other links
        return navigationType == UIWebViewNavigationType.other
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        replaceIndicatorViewWithReload()
    }
}
