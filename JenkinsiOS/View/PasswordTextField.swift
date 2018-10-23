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

    @IBInspectable var openImage = UIImage(named: "ic-showpassword")?.withRenderingMode(.alwaysTemplate)
    @IBInspectable var closedImage = UIImage(named: "key")?.withRenderingMode(.alwaysTemplate)

    var buttonInset: (x: CGFloat, y: CGFloat) = (10, 7)

    override var text: String? {
        didSet {
            if oldValue == "" || oldValue == nil {
                setButtonImage()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubViews()
        isSecureTextEntry = true
    }

    private func addSubViews() {
        let button = UIButton(type: .custom)

        rightView = button
        toggleSecureTextButton = button
        rightViewMode = .always

        setButtonImage()

        button.addTarget(self, action: #selector(toggleIsSecureTextEntry), for: .touchUpInside)
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    @objc private func editingChanged() {
        guard text != nil && !text!.isEmpty
        else { toggleSecureTextButton?.setImage(nil, for: .normal); return }
        setButtonImage()
    }

    private func setButtonImage() {
        toggleSecureTextButton?.setImage(imageForSecureTextState(), for: .normal)
        toggleSecureTextButton?.imageView?.tintColor = Constants.UI.silver
    }

    private func imageForSecureTextState() -> UIImage? {
        guard text != nil && !text!.isEmpty
        else { return nil }
        return (isSecureTextEntry) ? openImage : closedImage
    }

    @objc func toggleIsSecureTextEntry() {
        isSecureTextEntry = !isSecureTextEntry
        setButtonImage()
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        if text == nil || text!.isEmpty {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }

        let widthAndHeight = bounds.height - buttonInset.y * 2
        return CGRect(x: bounds.maxX - buttonInset.x - widthAndHeight, y: buttonInset.y, width: widthAndHeight, height: widthAndHeight)
    }
}
