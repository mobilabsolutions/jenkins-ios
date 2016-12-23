//
//  ParameterTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 31.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ParameterTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var delegate: ParameterTableViewCellDelegate?
    
    fileprivate var parameterInputView: UIView?
    
    var parameter: Parameter?{
        didSet{
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI(){
        nameLabel.text = parameter?.name
        descriptionLabel.text = parameter?.description ?? "No description provided"
        parameterInputView?.removeFromSuperview()
        
        guard let type = parameter?.type
            else { return }
        
        if nameLabel.text == nil || nameLabel.text!.isEmpty{
            nameLabel.text = type.rawValue
        }
        
        switch type{
            case .boolean: parameterInputView = switchView()
            case .run, .choice: parameterInputView = textFieldWithPickerView()
            case .string, .file, .textBox: parameterInputView = textField(password: false)
            case .password: parameterInputView = textField(password: true)
            case .unknown: parameterInputView = label(); descriptionLabel.text = "Unknown parameter type"
        }
        
        containerView.addSubview(parameterInputView!)
        containerView.sizeToFit()
        
        parameterInputView?.translatesAutoresizingMaskIntoConstraints = false
        
        parameterInputView?.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        parameterInputView?.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        parameterInputView?.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        
        self.setNeedsLayout()
    }
    
    private func getViewsValue() -> String?{
        guard let inputView = parameterInputView
            else { return nil }
        
        switch inputView {
        case is UITextField:
            return (inputView as! UITextField).text
        case is UISwitch:
            return "\((inputView as! UISwitch).isOn)"
        default:
            return nil
        }
    }
    
    @objc private func didEdit(){
        guard let parameter = parameter
            else { return }
        delegate?.set(value: getViewsValue(), for: parameter)
    }
    
    private func switchView() -> UISwitch{
        let switchView = UISwitch()
        
        switchView.isOn = (parameter?.defaultParameterString != nil ? Bool(parameter!.defaultParameterString!) : nil) ?? false
        switchView.addTarget(self, action: #selector(didEdit), for: .valueChanged)
            
        return switchView
    }
    
    private func textField(password: Bool) -> UITextField{
        let textField = UITextField()
        textField.placeholder = parameter?.name
        textField.text = parameter?.defaultParameterString
        textField.addTarget(self, action: #selector(didEdit), for: .editingChanged)
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.sizeToFit()
        textField.isSecureTextEntry = password
        return textField
    }
    
    private func textFieldWithPickerView() -> UITextField{
        let textField = self.textField(password: false)
        textField.borderStyle = .none
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        
        let row = (parameter?.additionalData as? [AnyObject])?.index(where: { textField.text == "\($0)" }) ?? 0
        picker.selectRow(row, inComponent: 0, animated: false)
        
        textField.inputView = picker
        return textField
    }
    
    private func label() -> UILabel{
        let label = UILabel()
        label.text = parameter?.defaultParameterString != nil ? parameter?.defaultParameterString : "No default value"
        label.numberOfLines = 0
        label.textColor = .lightText
        return label
    }
}

extension ParameterTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (parameter?.additionalData as? [Any])?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let value = (parameter?.additionalData as? [AnyObject])?[row]
            else { return nil }
        return "\(value)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let value = (self.parameter?.additionalData as? [AnyObject])?[row], let parameter = parameter
            else { return }
        (parameterInputView as? UITextField)?.text = "\(value)"
        delegate?.set(value: "\(value)", for: parameter)
    }
}
