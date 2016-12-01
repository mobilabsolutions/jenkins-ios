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
    
    var dismissOnTap: Bool = true
    
    var delegate: ModalInformationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.cornerRadius = 20
        self.containerView.clipsToBounds = true
        self.containerView.alpha = 1.0
        self.containerView.isOpaque = true
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.view.isOpaque = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registeredTapOutside))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func with(title: String?, detailView: UIView?){
        titleLabel.text = title
        centerView.subviews.forEach{
            $0.removeFromSuperview()
        }
        guard let detailView = detailView
            else { return }
        
        centerView.addSubview(detailView)
        addConstraintsTo(detailView: detailView)
    }
    
    private func addConstraintsTo(detailView: UIView){
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        detailView.widthAnchor.constraint(lessThanOrEqualTo: centerView.widthAnchor).isActive = true
        detailView.heightAnchor.constraint(lessThanOrEqualTo: centerView.heightAnchor).isActive = true
        detailView.centerXAnchor.constraint(equalTo: centerView.centerXAnchor).isActive = true
        detailView.centerYAnchor.constraint(equalTo: centerView.centerYAnchor).isActive = true
    }
    
    func withLoadingIndicator(title: String?){
        let loadingIndicator = LoadingIndicatorImageView(image: nil)        
        self.with(title: title, detailView: loadingIndicator)
    }
    
    @objc private func registeredTapOutside(){
        if dismissOnTap{
            self.dismiss(animated: true){
                self.delegate?.didDismiss()
            }
        }
    }
}
