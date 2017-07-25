//
//  ParameterTableViewCellDelegate.swift
//  JenkinsiOS
//
//  Created by Robert on 31.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol ParameterTableViewCellDelegate {
    func set(value: String?, for parameter: Parameter)
}
