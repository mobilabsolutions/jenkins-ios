//
//  ParametersViewControllerDelegate.swift
//  JenkinsiOS
//
//  Created by Robert on 30.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol ParametersViewControllerDelegate {
    func build(parameters: [ParameterValue], completion: @escaping (Error?) -> ())
    func updateAccount(data: [String: String?])
}
