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
    var directionButton: UIButton = UIButton(type: .system)
    var request: URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        consoleWebView.allowsLinkPreview = true
        consoleWebView.delegate = self
        addDirectionButton()

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
        enableDirectionButton(enable: false)
        consoleWebView.loadRequest(request)
    }

    func addDirectionButton(){

        directionButton.addTarget(self, action: #selector(scrollToBottom), for: .touchUpInside)
        directionButton.setImage(UIImage(named: "downArrow"), for: .normal)
        enableDirectionButton(enable: false)

        view.addSubview(directionButton)

        directionButton.translatesAutoresizingMaskIntoConstraints = false

        directionButton.bottomAnchor.constraint(equalTo: self.consoleWebView.bottomAnchor, constant: -20).isActive = true
        directionButton.rightAnchor.constraint(equalTo: self.consoleWebView.rightAnchor, constant: -16).isActive = true
        directionButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        directionButton.widthAnchor.constraint(lessThanOrEqualTo: directionButton.heightAnchor).isActive = true
    }

    func enableDirectionButton(enable: Bool){
        UIView.animate(withDuration: 0.4, animations: {
            [unowned self] in
            self.directionButton.alpha = enable ? 1.0 : 0.0
        }, completion: { _ in
            self.directionButton.isHidden = !enable
         })
    }

    func scrollToBottom(){
        let y = consoleWebView.scrollView.contentSize.height - consoleWebView.frame.height
        self.consoleWebView.scrollView.scrollRectToVisible(
                CGRect(x: 0.0, y: y >= 0 ? y : 0.0, width: consoleWebView.frame.width, height: consoleWebView.frame.height),
                animated: true
        )
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
        enableDirectionButton(enable: true)
    }
}
