//
//  BaseTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 19.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    var emptyTableViewText: String?
    var emptyTableViewImage: UIImage?
    
    var viewForEmptyMessage: UIView?
    
    private var emptyTableViewImageView: UIImageView?
    private var emptyTableViewLabel: UILabel?
    
    func numberOfSections() -> Int{
        return 0
    }
    
    func tableViewIsEmpty() -> Bool{
        return numberOfSections() == 0
    }
    
    final override func numberOfSections(in tableView: UITableView) -> Int {
        setUpTableView(empty: tableViewIsEmpty())
        return numberOfSections()
    }
    
    private func setUpTableView(empty: Bool){
        if empty{
            setupEmptyTableView()
        }
        else{
            setupNotEmptyTableView()
        }
        
        setTableViewSeparatorStyle(for: empty)
    }
    
    private func setupNotEmptyTableView(){
        tableView.backgroundView = nil
    }
    
    private func setupEmptyTableView(){
        let container = getContainerViewForEmptyTableView()
        addContainerToEmptyMessageView(container: container)
        addEmptyTableViewText(in: container)
        
        guard let label = emptyTableViewLabel
            else { return }
        
        addEmptyTableViewImage(in: container, relativeTo: label)
    }
    
    private func addContainerToEmptyMessageView(container: UIView){
        if let view = viewForEmptyMessage{
            view.addSubview(container)
            addConstraintsToEmptyTableView(container: container, in: view)
        }
        else{
            tableView.backgroundView = container
        }
    }
    
    private func addConstraintsToEmptyTableView(container: UIView, in view: UIView){
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        container.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        container.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    private func addEmptyTableViewText(in view: UIView){
        let label = getLabelForEmptyTableView()
        label.text = emptyTableViewText
        
        view.addSubview(label)
        addConstraintsToEmptyTableView(label: label, in: view)
    }
    
    private func addEmptyTableViewImage(in view: UIView, relativeTo label: UIView){
        let imageView = getImageViewForEmptyTableView()
        imageView.image = emptyTableViewImage
        
        view.addSubview(imageView)
        addConstraintsToEmptyTableView(imageView: imageView, in: view, relativeTo: label)
    }
    
    private func addConstraintsToEmptyTableView(imageView: UIView, in view: UIView, relativeTo label: UIView){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.layoutMarginsGuide
        
        imageView.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
    }
    
    private func addConstraintsToEmptyTableView(label: UIView, in view: UIView){
        let guide = view.layoutMarginsGuide
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: 20).isActive = true
        
        label.sizeToFit()
    }
    
    private func getContainerViewForEmptyTableView() -> UIView{
        let container = UIView()
        container.backgroundColor = UIColor(patternImage: UIImage(named: "noiseTexture")!)
        return container
    }
    
    private func getImageViewForEmptyTableView() -> UIImageView{
        let imageView = emptyTableViewImageView ?? UIImageView()
        emptyTableViewImageView = imageView
        
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.5
        
        return imageView
    }
    
    private func getLabelForEmptyTableView() -> UILabel{
        
        let label = emptyTableViewLabel ?? UILabel()
        emptyTableViewLabel = label
        
        label.numberOfLines = 0
        label.textColor = UIColor.black
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    private func setTableViewSeparatorStyle(for empty: Bool){
        tableView.separatorStyle = empty ? .none : .singleLine
    }
}
