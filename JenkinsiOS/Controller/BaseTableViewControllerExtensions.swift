//
//  BaseTableViewControllerExtensions.swift
//  JenkinsiOS
//
//  Created by Robert on 27.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

extension BaseTableViewController {
    
    enum EmptyTableViewReason: String{
        case noData = "There does not seem to be anything here"
        case loading = "Loading data..."
        case error = "An error occurred"
    }
    
    struct ActionDescriptor {
        let actionTitle: String
    }
    
    func emptyTableView(for reason: EmptyTableViewReason, customString: String? = nil, action: ActionDescriptor? = nil) {
        switch reason {
        case .noData: emptyTableViewForNoData(text: customString ?? reason.rawValue, action: action)
        case .loading: emptyTableViewForLoading(text: customString ?? reason.rawValue, action: action)
        case .error: emptyTableViewForError(text: customString ?? reason.rawValue, action: action)
        }
    }

    private func emptyTableViewForLoading(text: String, action: ActionDescriptor?) {
        emptyTableViewText = text
        let loader = LoadingIndicatorView()
        emptyTableViewContentView = loader
        loader.startAnimating()
    }
    
    private func emptyTableViewForNoData(text: String, action: ActionDescriptor?) {
        emptyTableViewText = text
        
        guard let image = UIImage(named: "ic-empty-jobs")
            else { return }
        
        emptyTableViewContentView = imageViewForEmptyTableView(image: image)
    }
    
    private func emptyTableViewForError(text: String, action: ActionDescriptor?) {
        emptyTableViewText = text
        
        actionTitle = action?.actionTitle
        
        guard let image = UIImage(named: "sadFace")
            else { return }
        
        emptyTableViewContentView = imageViewForEmptyTableView(image: image)
    }
    
    private func imageViewForEmptyTableView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
