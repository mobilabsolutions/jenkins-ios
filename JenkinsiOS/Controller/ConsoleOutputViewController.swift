//
//  ConsoleOutputViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import WebKit

class ConsoleOutputViewController: UIViewController {

    var consoleWebView: WKWebView?
    var directionButton: UIButton = UIButton(type: .system)
    var request: URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = .all
        }
        consoleWebView = WKWebView(frame: self.view.frame, configuration: configuration)

        consoleWebView?.navigationDelegate = self
        addConsoleWebViewConstraints()
        addDirectionButton()

        reload()
    }

    func addConsoleWebViewConstraints(){
        guard let consoleWebView = self.consoleWebView else { return }
        view.addSubview(consoleWebView)
        consoleWebView.translatesAutoresizingMaskIntoConstraints = false
        consoleWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        consoleWebView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        consoleWebView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        consoleWebView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        consoleWebView.scrollView.contentInset = UIEdgeInsets(top: 20 + (navigationController?.navigationBar.frame.height ?? 0), left: 0, bottom: 0, right: 0)
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
    
    @objc func reload(){
        guard let request = request
            else { return }
        
        addIndicatorView()
        enableDirectionButton(enable: false)
        consoleWebView?.load(request)
    }

    func addDirectionButton(){

        guard let consoleWebView = self.consoleWebView else { return }

        directionButton.addTarget(self, action: #selector(scrollToBottom), for: .touchUpInside)
        directionButton.setImage(UIImage(named: "downArrow"), for: .normal)
        enableDirectionButton(enable: false)

        view.addSubview(directionButton)

        directionButton.translatesAutoresizingMaskIntoConstraints = false

        directionButton.bottomAnchor.constraint(equalTo: consoleWebView.bottomAnchor, constant: -20).isActive = true
        directionButton.rightAnchor.constraint(equalTo: consoleWebView.rightAnchor, constant: -16).isActive = true
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

    @objc func scrollToBottom(){
        guard let consoleWebView = self.consoleWebView else { return }

        let y = consoleWebView.scrollView.contentSize.height - consoleWebView.frame.height
        consoleWebView.scrollView.scrollRectToVisible(
                CGRect(x: 0.0, y: y >= 0 ? y : 0.0, width: consoleWebView.frame.width, height: consoleWebView.frame.height),
                animated: true
        )
    }
}

//MARK: - Webview delegate
extension ConsoleOutputViewController: WKNavigationDelegate{

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        replaceIndicatorViewWithReload()
        enableDirectionButton(enable: true)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated{
            if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            decisionHandler(.cancel)
        }
        else{
            decisionHandler(.allow)
        }
    }

}
