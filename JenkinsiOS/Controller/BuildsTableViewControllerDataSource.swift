//
//  BuildsTableViewControllerDataSource.swift
//  JenkinsiOS
//
//  Created by Robert on 03.11.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol BuildsTableViewControllerDataSource {
    func loadBuilds(completion: @escaping ([Build]?, [(String, Build)]?) -> Void)
}
