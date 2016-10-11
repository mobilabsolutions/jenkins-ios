//
//  BuildViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 29.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildViewController: UIViewController {

    //MARK: - Instance variables
    
    var build: Build?
    var account: Account?
    
    
    private var favoriteImage: UIImage?{
        get{
            return (build != nil && build!.isFavorite) ? UIImage(named: "HeartFull") : UIImage(named: "HeartEmpty")
        }
    }
    //MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var consoleWebView: UIWebView!
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        updateUIContent()
        performRequests()
    }

    
    //MARK: - Actions
    
    @objc private func toggleLike(){
        guard let account = account
            else { return }
        build?.toggleFavorite(account: account)
        (navigationItem.titleView as? UIImageView)?.image = favoriteImage
    }
    
    //MARK: - Data loading and displaying
    
    private func performRequests(){
        guard let build = build
            else { return }
        
        let request = URLRequest(url: build.consoleOutputUrl.using(scheme: "https")!)
        consoleWebView.loadRequest(request)
        
        
        if build.isFullVersion == false, let account = account{
            let userRequest = UserRequest(requestUrl: build.url, account: account)
            
            NetworkManager.manager.completeBuildInformation(userRequest: userRequest, build: build, completion: { (_, error) in
                //FIXME: Actually display errors
                DispatchQueue.main.async {
                    self.updateUIContent()
                }
            })
        }
    }
    
    private func setUpUI(){
        consoleWebView.allowsLinkPreview = true
        consoleWebView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleLike))
        navigationItem.titleView = UIImageView(image: favoriteImage)
        navigationItem.titleView?.isUserInteractionEnabled = true
        navigationItem.titleView?.addGestureRecognizer(recognizer)
    }
    
    private func updateUIContent(){
        guard let build = build
            else { return }
        
        nameLabel.text = build.fullDisplayName ?? build.displayName ?? "Build #\(build.number)"
        urlLabel.text = "\(build.url)"
    }
}

//MARK: - Webview delegate
extension BuildViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // We do not want the user to be able to tap any other links
        return navigationType == UIWebViewNavigationType.other
    }
}
