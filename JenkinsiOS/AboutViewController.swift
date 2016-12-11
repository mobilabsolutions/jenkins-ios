//
//  AboutViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 08.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet var aboutTextView: UITextView!
    @IBOutlet var creditsTextView: UITextView!
    
    let aboutInformationManager = AboutInformationManager()
    var reviewHandler: ReviewHandler?
    
    @IBAction func review(_ sender: Any) {
        reviewHandler?.triggerReview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        aboutTextView.text = aboutInformationManager.getAboutText() ?? ""
        creditsTextView.text = aboutInformationManager.getCreditsText() ?? ""
        
        reviewHandler = ReviewHandler(presentOn: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
