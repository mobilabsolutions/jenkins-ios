//
//  PasswordTextField.swift
//  JenkinsiOS
//
//  Created by Robert on 21.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

@IBDesignable class PasswordTextField: UITextField {
    
    private var toggleSecureTextButton: UIButton?
    
    @IBInspectable var openImage = UIImage(named: "openEye")
    @IBInspectable var closedImage = UIImage(named: "key")
    
    @IBInspectable var buttonInset: (x: Int, y: Int) = (10, 7)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        addSubViews()
        self.isSecureTextEntry = true
    }
    
    private func addSubViews(){
        
        let button = UIButton(type: .custom)
        button.setImage(imageForSecureTextState(), for: .normal)
        setButtonImage()
        
        self.leftView = button
        self.toggleSecureTextButton = button
        self.leftViewMode = .always
        
        button.addTarget(self, action: #selector(toggleIsSecureTextEntry), for: .touchUpInside)
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc private func editingChanged(){
        guard self.text != nil && !self.text!.isEmpty
            else { toggleSecureTextButton?.setImage(nil, for: .normal); return }
        setButtonImage()
    }
    
    private func setButtonImage(){
        toggleSecureTextButton?.setImage(imageForSecureTextState(), for: .normal)
    }
    
    private func imageForSecureTextState() -> UIImage?{
        guard self.text != nil && !self.text!.isEmpty
            else { return nil }
        return (self.isSecureTextEntry) ? openImage : closedImage
    }
    
    func toggleIsSecureTextEntry(){
        isSecureTextEntry = !isSecureTextEntry
        setButtonImage()
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        
        if text == nil || text!.isEmpty{
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        let widthAndHeight = Int(bounds.height) - buttonInset.y * 2
        return CGRect(x: buttonInset.x, y: buttonInset.y, width: widthAndHeight, height: widthAndHeight)
    }
}
