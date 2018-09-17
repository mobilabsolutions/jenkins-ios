//
//  OnBoardingViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 21.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {
    var option: OnBoardingOption?

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageName = option?.imageName {
            imageView.image = UIImage(named: imageName)
        }

        titleLabel.text = option?.title
        subtitleLabel.text = option?.subtitle
    }
}
