//
//  BaseTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 19.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

@IBDesignable class BaseTableViewController: UITableViewController {

    /// The type of content that should be logged
    var contentType: LoggableContentView?

    /// The text that should be displayed if the table view is empty
    @IBInspectable var emptyTableViewText: String? {
        didSet {
            emptyTableViewLabel?.text = emptyTableViewText
        }
    }
    
    var emptyTableViewContentView: UIView? {
        didSet {
            if oldValue?.superview != nil, let container = tableView.backgroundView, let label = emptyTableViewLabel {
                oldValue?.removeFromSuperview()
                addEmptyTableViewContentView(in: container, relativeTo: label)
            }
        }
    }

    struct ActionDescriptor {
        let actionTitle: String
        let callback: () -> ()
    }
    
    var actionDescriptor: ActionDescriptor? {
        didSet {
            if let button = emptyTableViewActionButton, button.superview != nil, let text = actionDescriptor?.actionTitle {
                button.setTitle(text, for: .normal)
            }
            else if actionDescriptor == nil {
                emptyTableViewActionButton?.removeFromSuperview()
            }
            else if let container = emptyTableViewContentView?.superview {
                addEmptyTableViewActionButton(to: container)
            }
        }
    }
    
    /// The view that the text and image should be displayed in, if the table view is empty
    private var emptyTableViewLabel: UILabel?
    
    private var emptyTableViewActionButton: UIButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let animatable = emptyTableViewContentView as? Animatable {
            animatable.startAnimating()
        }
        
        guard let contentView = contentType
              else { return }

        LoggingManager.loggingManager.log(contentView: contentView)
    }
    
    /// How many sections there are in the given table view
    ///
    /// - Returns: The number of sections in this table view
    func numberOfSections() -> Int{
        return 0
    }
    
    /// The tableview's state of emptiness
    ///
    /// - Returns: Whether or not the table view is currently defined as empty
    func tableViewIsEmpty() -> Bool{
        return numberOfSections() == 0
    }
    
    final override func numberOfSections(in tableView: UITableView) -> Int {
        setUpTableView(empty: tableViewIsEmpty())
        return numberOfSections()
    }
    
    private func setUpTableView(empty: Bool) {
        if empty {
            setupEmptyTableView()
        }
        else {
            setupNotEmptyTableView()
        }
        
        setTableViewSeparatorStyle(for: empty)
    }
    
    private func setupNotEmptyTableView() {
        tableView.backgroundView = nil
    }
    
    private func setupEmptyTableView() {
        let container = tableView.backgroundView ?? createContainerViewForEmptyTableView()
        addContainerToEmptyMessageView(container: container)
        addEmptyTableViewText(in: container)
        
        guard let emptyTableViewLabel = emptyTableViewLabel
            else { return }
        
        addEmptyTableViewContentView(in: container, relativeTo: emptyTableViewLabel)
    }
    
    private func addContainerToEmptyMessageView(container: UIView) {
        guard tableView.backgroundView == nil
            else { return }
        tableView.backgroundView = container
    }
    
    private func addConstraintsToEmptyTableView(container: UIView, in view: UIView) {
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        container.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        container.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    private func addEmptyTableViewText(in view: UIView) {
        let label = getLabelForEmptyTableView()
        label.text = emptyTableViewText
        label.textColor = Constants.UI.greyBlue
        label.font = UIFont.boldDefaultFont(ofSize: 24)
        
        view.addSubview(label)
        addConstraintsToEmptyTableView(label: label, in: view)
    }
    
    private func addConstraintsToEmptyTableView(label: UIView, in view: UIView){
        let guide = view.layoutMarginsGuide
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: 70).isActive = true
        label.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        label.sizeToFit()
    }
    
    private func addEmptyTableViewActionButton(to container: UIView) {
        let button = BigButton(type: .custom)
        button.setTitle(self.actionDescriptor?.actionTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(emptyTableViewAction), for: .touchUpInside)
        
        container.addSubview(button)
        
        button.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8).isActive = true
        button.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -8).isActive = true
        button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -120).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.emptyTableViewActionButton = button
    }
    
    private func addEmptyTableViewContentView(in container: UIView, relativeTo label: UIView) {
        guard let contentView = self.emptyTableViewContentView
            else { return }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(contentView)
        addConstraintsToEmptyTableView(contentView: contentView, in: container, relativeTo: label)
    }
    
    private func addConstraintsToEmptyTableView(contentView: UIView, in view: UIView, relativeTo label: UIView){
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.layoutMarginsGuide
        
        contentView.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
    }
    
    private func createContainerViewForEmptyTableView() -> UIView {        
        let container = UIView()
        container.backgroundColor = Constants.UI.backgroundColor
        return container
    }
    
    private func getLabelForEmptyTableView() -> UILabel {
        
        let label = emptyTableViewLabel ?? UILabel()
        emptyTableViewLabel = label
        
        label.numberOfLines = 0
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    @objc private func emptyTableViewAction() {
        self.actionDescriptor?.callback()
    }
    
    private func setTableViewSeparatorStyle(for empty: Bool){
        tableView.separatorStyle = empty ? .none : separatorStyleForNonEmpty()
    }
    
    func separatorStyleForNonEmpty() -> UITableViewCell.SeparatorStyle {
        return .singleLine
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpTableView(empty: true)
    }
}
