//
//  UserViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 17.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    var user: User? {
        didSet {
            updateLabels()
        }
    }
    
    @IBOutlet weak var userIdLabel: UILabel?
    @IBOutlet weak var fullNameLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    private func updateLabels() {
        userIdLabel?.text = user?.id
        fullNameLabel?.text = user?.fullName
        descriptionLabel?.text = user?.description ?? "No description"
    }

}
