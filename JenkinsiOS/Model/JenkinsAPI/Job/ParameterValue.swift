//
//  ParameterValue.swift
//  JenkinsiOS
//
//  Created by Robert on 31.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ParameterValue {
    var parameter: Parameter
    var value: String?

    init(parameter: Parameter, value: String? = nil) {
        self.parameter = parameter
        self.value = value
    }
}
