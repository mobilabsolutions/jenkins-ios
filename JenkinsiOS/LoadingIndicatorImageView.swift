//
//  LoadingIndicatorImageView.swift
//  JenkinsiOS
//
//  Created by Robert on 28.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class LoadingIndicatorImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(with: UIImage(named: "Jenkins_Loader"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(with: UIImage(named: "Jenkins_Loader"))
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup(with: image ?? UIImage(named: "Jenkins_Loader"))
    }
    
    convenience init(images: [UIImage]){
        self.init(image: images.first)
        if images.count > 0{
            set(animatingImages: images)
        }
    }
    
    private func set(animatingImages: [UIImage]){
        self.animationImages = animatingImages
        self.animationDuration = Double(animatingImages.count) * 0.2
        self.startAnimating()
    }
    
    private func setup(with image: UIImage?){
        self.image = image
        self.contentMode = .scaleAspectFit
        self.alpha = 0.5
        
        self.addRotatingAnimation()
    }
    
    private func addRotatingAnimation(){
        self.layer.add(getRotatingAnimation(), forKey: "Rotation")
    }
    
    private func getRotatingAnimation() -> CAAnimation{
        let animation = CABasicAnimation(keyPath: "transform")
        
        var rotation = CATransform3DMakeRotation(CGFloat(M_PI), 0.1, 1, 0.1)
        rotation.m34 = 1.0/800.0
        
        animation.toValue = rotation
        animation.duration = 3.0
        animation.autoreverses = true
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        animation.repeatCount = .infinity
        
        return animation
    }
}
