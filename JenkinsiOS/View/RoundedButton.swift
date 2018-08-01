//
//  RoundedButton.swift
//  JenkinsiOS
//
//  Created by Robert on 27.07.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    var selectedColor: UIColor = Constants.UI.darkGrey
    var deselectedColor: UIColor = Constants.UI.silver
    
    var option: CustomStringConvertible? {
        didSet {
            updateButtonText()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        self.layer.cornerRadius = 10
        self.backgroundColor = deselectedColor
        self.setTitleColor(.white, for: .normal)
        
        self.titleEdgeInsets = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)
        
        self.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    @objc private func didTap() {
        self.isSelected = !self.isSelected
    }
    
    private func updateButtonText() {
        let attributedString = NSMutableAttributedString(string: option?.description ?? "",
                                                         attributes: [.font: UIFont.boldDefaultFont(ofSize: 11), .foregroundColor: UIColor.white])
        
        if isSelected {
            // FIXME: This is not nice and should be changed!
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "arrow-down")
            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(NSAttributedString(string: " "))
            attributedString.append(attachmentString)
        }
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? selectedColor : deselectedColor
            updateButtonText()
        }
    }

    override func sizeToFit() {
        super.sizeToFit()
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y,
                            width: self.frame.size.width + 35, height: self.frame.size.height)
    }
}
