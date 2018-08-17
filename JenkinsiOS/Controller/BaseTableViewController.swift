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
    /// The image that should be displayed if the table view is empty
    @IBInspectable var emptyTableViewImages: [UIImage] = []{
        didSet {
            setImageForEmptyTableViewImageView(view: emptyTableViewImageView)
        }
    }
    
    /// The view that the text and image should be displayed in, if the table view is empty
    var viewForEmptyMessage: UIView?
    
    /// Whether or not the image should rotate
    @IBInspectable var emptyTableViewImageViewIsForLoading: Bool = false {
        didSet {
            
            // Did anything change?
            guard emptyTableViewImageViewIsForLoading != oldValue
                else { return }
            
            if emptyTableViewImageViewIsForLoading {
                let loadingIndicatorView = LoadingIndicatorImageView(images: emptyTableViewImages)
                emptyTableViewImageView = loadingIndicatorView
            }
            else {
                emptyTableViewImageView = UIImageView()
                setUpTableView(empty: tableViewIsEmpty())
            }
        }
    }
    
    private var emptyTableViewImageView: UIImageView?
    private var emptyTableViewLabel: UILabel?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let loadingIndicator = emptyTableViewImageView as? LoadingIndicatorImageView {
            loadingIndicator.stopAnimation()
            loadingIndicator.startAnimation()
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
        let container = getContainerViewForEmptyTableView()
        addContainerToEmptyMessageView(container: container)
        addEmptyTableViewText(in: container)
        
        guard let label = emptyTableViewLabel
            else { return }
        
        addEmptyTableViewImage(in: container, relativeTo: label)
    }
    
    private func addContainerToEmptyMessageView(container: UIView) {
        if let view = viewForEmptyMessage {
            view.addSubview(container)
            addConstraintsToEmptyTableView(container: container, in: view)
        }
        else {
            tableView.backgroundView = container
        }
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
        label.textColor = .darkGray
        
        label.font = UIFont(name: "Bangla Sangam MN", size: UIFont.labelFontSize)
        
        view.addSubview(label)
        addConstraintsToEmptyTableView(label: label, in: view)
    }
    
    private func addEmptyTableViewImage(in view: UIView, relativeTo label: UIView) {
        let imageView = getImageViewForEmptyTableView()
        setImageForEmptyTableViewImageView(view: imageView)
        
        view.addSubview(imageView)
        addConstraintsToEmptyTableView(imageView: imageView, in: view, relativeTo: label)
    }
    
    private func setImageForEmptyTableViewImageView(view: UIImageView?) {
        
        view?.stopAnimating()
        
        if emptyTableViewImages.count > 1{
            view?.animationImages = emptyTableViewImages
            view?.animationDuration = 0.4 * Double(emptyTableViewImages.count)
            view?.startAnimating()
        }
        else{
            view?.image = emptyTableViewImages.first
        }
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
        label.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: 70).isActive = true
        
        label.sizeToFit()
    }
    
    private func getContainerViewForEmptyTableView() -> UIView{
        let container = UIView()
        container.backgroundColor = Constants.UI.backgroundColor
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
        tableView.separatorStyle = empty ? .none : separatorStyleForNonEmpty()
    }
    
    func separatorStyleForNonEmpty() -> UITableViewCellSeparatorStyle {
        return .singleLine
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpTableView(empty: true)
    }
}
