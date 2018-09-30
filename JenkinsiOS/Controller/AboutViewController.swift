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

    @IBAction func review(_: Any) {
        reviewHandler?.triggerReview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        aboutTextView.text = aboutInformationManager.getAboutText() ?? ""
        creditsTextView.text = aboutInformationManager.getCreditsText() ?? ""

        reviewHandler = ReviewHandler(presentOn: self)
    }
}
