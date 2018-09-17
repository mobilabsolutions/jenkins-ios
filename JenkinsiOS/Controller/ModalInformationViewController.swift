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
    @IBOutlet weak var centerView: UIView?
    @IBOutlet weak var containerView: UIView!
    
    var dismissOnTap: Bool = true
    
    weak var delegate: ModalInformationViewControllerDelegate?
    
    private var viewTitle: String?
    private var detailView: UIView?
    
    //MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = viewTitle
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addDetailView()
        setBackgroundTransparent()
        
        if let animatable = detailView as? Animatable {
            animatable.startAnimating()
        }
    }
    
    //MARK: - Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(title: String?, detailView: UIView?){
        self.init(nibName: "ModalInformationViewController", bundle: Bundle.main)
        set(title: title, detailView: detailView)
    }
    
    static func withLoadingIndicator(title: String?) -> ModalInformationViewController {
        return ModalInformationViewController(title: title, detailView: LoadingIndicatorView())
    }
    
    func set(title: String?, detailView: UIView?){
        self.viewTitle = title
        self.detailView = detailView
        
        addDetailView()
    }
    
    // MARK: View helper methods
    
    private func addConstraintsTo(detailView: UIView){
        
        guard let centerView = centerView
            else { return }
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        detailView.widthAnchor.constraint(lessThanOrEqualTo: centerView.widthAnchor).isActive = true
        detailView.heightAnchor.constraint(lessThanOrEqualTo: centerView.heightAnchor).isActive = true
        detailView.centerXAnchor.constraint(equalTo: centerView.centerXAnchor).isActive = true
        detailView.centerYAnchor.constraint(equalTo: centerView.centerYAnchor).isActive = true
    }
    
    @objc private func registeredTapOutside(gestureRecognizer: UIGestureRecognizer){
        if dismissOnTap && isOutsideContainerView(point: gestureRecognizer.location(in: self.view)){
            self.dismiss(animated: true){
                self.delegate?.didDismiss()
            }
        }
    }
    
    private func isOutsideContainerView(point: CGPoint) -> Bool{
        return !self.containerView.frame.contains(point)
    }
    
    private func setBackgroundTransparent() {
        self.containerView.layer.cornerRadius = 20
        self.containerView.clipsToBounds = true
        self.containerView.alpha = 1.0
        self.containerView.isOpaque = true
        self.view.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
        self.view.isOpaque = false
    }
    
    private func addGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registeredTapOutside))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    private func addDetailView() {
        centerView?.subviews.forEach{
            $0.removeFromSuperview()
        }
        
        guard let detailView = detailView
            else { return }
        
        centerView?.addSubview(detailView)
        addConstraintsTo(detailView: detailView)
    }

}
