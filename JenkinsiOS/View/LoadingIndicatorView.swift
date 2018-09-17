//
//  LoadingIndicatorView.swift
//  JenkinsiOS
//
//  Created by Robert on 23.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit
import AVFoundation

protocol Animatable {
    func startAnimating()
    func stopAnimating()
}

class LoadingIndicatorView: UIView, Animatable {
    private let imageView = UIImageView()
    private let containerView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let animation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation()

        animation.duration = 1
        animation.keyPath = "startPoint"
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        return animation
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addImageView()
        addAnimatingLayer()
    }
    
    func startAnimating() {
        animation.path = UIBezierPath(arcCenter: CGPoint(x: 0.5, y: 0.5), radius: 0.5, startAngle: .pi, endAngle: .pi * 3, clockwise: true).cgPath
        gradientLayer.add(animation, forKey: "animation")
    }
    
    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "animation")
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        stopAnimating()
    }
    
    private func addImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "jenkins-loader")
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func addAnimatingLayer() {
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layer = gradientLayer
        layer.frame = AVMakeRect(aspectRatio: imageView.image?.size ?? .zero, insideRect: containerView.bounds)
        layer.colors = [
            Constants.UI.brightAqua.cgColor,
            Constants.UI.clearBlue.cgColor
        ]
        
        layer.startPoint = CGPoint(x: 0.5, y: 1.0)
        layer.endPoint = CGPoint(x: 0.5, y: 0.5)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY), radius: 0.375 * min(layer.frame.height, layer.frame.width),
                                       startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        layer.mask = shapeLayer
        
        if layer.superlayer == nil {
            containerView.layer.addSublayer(layer)
        }
    }
}
