//
//  CorneredView.swift
//  JenkinsiOS
//
//  Created by Robert on 10.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class CorneredView: UIView {
    var cornersToRound: UIRectCorner = []
    
    var borders: Set<BorderLocation> = []
    
    enum BorderLocation {
        case top
        case bottom
        case left
        case right
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if cornersToRound != [] {
            self.setCornerRounding(radius: 5, corners: cornersToRound)
        }
        
        for border in borders {
            switch border {
            case .top:
                addBorderLayer(x: 0, y: 0, width: self.bounds.width, height: 1)
            case .bottom:
                addBorderLayer(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
            case .left:
                addBorderLayer(x: 0, y: 0, width: 1, height: self.bounds.height)
            case .right:
                addBorderLayer(x: self.bounds.width - 1, y: 0, width: 1, height: self.bounds.height)
            }
        }
    }
    
    private func addBorderLayer(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let layer = CAShapeLayer()
        layer.backgroundColor = Constants.UI.paleGreyColor.cgColor
        layer.frame = CGRect(x: x, y: y, width: width, height: height)
        self.layer.addSublayer(layer)
    }
}
