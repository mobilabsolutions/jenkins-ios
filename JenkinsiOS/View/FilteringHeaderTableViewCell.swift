//
//  FilteringHeaderTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 30.07.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol FilteringHeaderTableViewCellDelegate {
    func didSelect(selected: CustomStringConvertible, cell: FilteringHeaderTableViewCell)
}

class FilteringHeaderTableViewCell: UITableViewCell {

    var options: [CustomStringConvertible] = [] {
        didSet {
            updateButtons()
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel?.text = title
        }
    }
    
    var delegate: FilteringHeaderTableViewCellDelegate?
    
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var titleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView?.alignment = .fill
        stackView?.distribution = .equalSpacing
        titleLabel?.textColor = Constants.UI.greyBlue
        self.titleLabel?.text = title
    }
    
    private func updateButtons() {
        stackView?.arrangedSubviews.forEach {
            stackView?.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for option in options {
            let view = RoundedButton()
            view.option = option
            view.sizeToFit()
            view.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            view.addTarget(self, action: #selector(didSelect(button:)), for: .touchUpInside)
            
            stackView?.addArrangedSubview(view)
        }
        
        (stackView?.arrangedSubviews.first as? RoundedButton)?.isSelected = true
    }
   
    func select(where predicate: (CustomStringConvertible) -> Bool) {
        var didSelectOne = false
        
        options.enumerated().forEach { (offset, element) in
            guard let button = stackView?.arrangedSubviews[offset] as? RoundedButton
                else { return }
            button.isSelected = predicate(element)
            didSelectOne = didSelectOne || button.isSelected
        }
        
        if !didSelectOne, let first = stackView?.arrangedSubviews.first as? RoundedButton, let option = first.option {
            first.isSelected = true
            delegate?.didSelect(selected: option, cell: self)
        }
    }
    
    @objc private func didSelect(button: RoundedButton) {
        for view in stackView?.arrangedSubviews ?? [] where view is RoundedButton {
            let roundedButton = view as! RoundedButton
            if button !== roundedButton && button.isSelected {
                roundedButton.isSelected = false
            }
        }
        
        if !button.isSelected, let first = stackView?.arrangedSubviews.first as? RoundedButton, let option = first.option {
            first.isSelected = true
            delegate?.didSelect(selected: option, cell: self)
        }
        else if let option = button.option {
            delegate?.didSelect(selected: option, cell: self)
        }
    }
}
