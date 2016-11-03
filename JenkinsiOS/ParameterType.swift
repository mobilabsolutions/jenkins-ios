//
//  ParameterType.swift
//  JenkinsiOS
//
//  Created by Robert on 30.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

enum ParameterType: String{
    case boolean = "BooleanParameterDefinition"
    case choice = "ChoiceParameterDefinition"
    case string = "StringParameterDefinition"
    case run = "RunParameterDefinition"
    case password = "PasswordParameterDefinition"
    case file = "FileParameterDefinition"
    case textBox = "TextParameterDefinition"
    case unknown = "Unknown"
    
    func additionalDataString() -> String?{
        switch self {
            case .choice:
                return Constants.JSON.choices
            case .run:
                return Constants.JSON.projectName
            default:
                return nil
        }
    }
    
    init(value: String){
        self = ParameterType(rawValue: value) ?? ParameterType.unknown
    }
}
