//
//  FavoriteCollectionViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 22.06.17.
//  Copyright © 2017 MobiLab Solutions. All rights reserved.
//

import UIKit
import QuartzCore

class FavoriteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    private var loadingIndicator: UIActivityIndicatorView?
    private var gradientLayer: CAGradientLayer?

    private func setup(){
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.colorBackgroundView.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: colorBackgroundView.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: colorBackgroundView.centerYAnchor).isActive = true
        
        self.loadingIndicator = loadingIndicator

        colorBackgroundView.backgroundColor = .clear

        colorBackgroundView.layer.cornerRadius = 8.0
        colorBackgroundView.clipsToBounds = true
        colorBackgroundView.layer.masksToBounds = true

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect:bounds, cornerRadius:colorBackgroundView.layer.cornerRadius).cgPath

        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = colorBackgroundView.bounds
        let gradientLayerFrame = gradientLayer!.frame
        gradientLayer?.startPoint = CGPoint(x: gradientLayerFrame.maxX, y: gradientLayerFrame.minY)
        gradientLayer?.endPoint = CGPoint(x: gradientLayerFrame.minX, y: gradientLayerFrame.maxY)
        self.colorBackgroundView.layer.insertSublayer(gradientLayer!, at: 0)
    }

    
    var favoritable: Favoratible? {
        didSet{
            
            if loadingIndicator == nil{ setup() }
            
            loadingIndicator?.stopAnimating()
            if let job = favoritable as? Job{
                setupForJob(job: job)
            }
            else if let build = favoritable as? Build{
                setupForBuild(build: build)
            }
            else {
                empty()
            }
        }
    }

    func setLoading(){
        
        if loadingIndicator == nil{ setup() }
        
        nameLabel.text = ""
        setGradientLayerColor(with: UIColor.lightGray.withAlphaComponent(0.7))
        typeLabel.text = ""

        loadingIndicator?.isHidden = false
        loadingIndicator?.startAnimating()
    }

    func setErrored(){
        if loadingIndicator == nil{ setup() }
        
        nameLabel.text = "Loading favorite failed"
        setGradientLayerColor(with: UIColor.darkGray)
        typeLabel.text = ""
        loadingIndicator?.stopAnimating()
    }

    private func setupForJob(job: Job){
        typeLabel.text = job.color != .folder ? "J" : "F"
        nameLabel.text = job.name
        
        setGradientLayerColor(with: job.describingColor())
    }

    private func setupForBuild(build: Build){
        typeLabel.text = "B"
        nameLabel.text = build.fullDisplayName ?? build.displayName ?? "Unknown"
        
        setGradientLayerColor(with: build.describingColor())
    }

    private func empty(){
        nameLabel.text = ""
        setGradientLayerColor(with: .clear)
        typeLabel.text = ""
    }

    private func setGradientLayerColor(with baseColor: UIColor){
        gradientLayer?.colors = [baseColor.withAlphaComponent(0.7).cgColor, baseColor.withAlphaComponent(0.6).cgColor]
    }
}
