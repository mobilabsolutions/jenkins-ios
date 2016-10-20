//
//  ModalInformationViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 20.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ModalInformationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.cornerRadius = 20
        self.containerView.clipsToBounds = true
        self.containerView.alpha = 1.0
        self.containerView.isOpaque = true
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.view.isOpaque = true
    }
    
    func with(title: String?, detailView: UIView?){
        titleLabel.text = title
        guard let detailView = detailView
            else { return }
        detailView.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(detailView)
        detailView.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        detailView.leftAnchor.constraint(equalTo: centerView.leftAnchor).isActive = true
        detailView.rightAnchor.constraint(equalTo: centerView.rightAnchor).isActive = true
        detailView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor).isActive = true
    }
}
