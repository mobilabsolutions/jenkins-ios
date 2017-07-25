//
//  ParameterType.swift
//  JenkinsiOS
//
//  Created by Robert on 30.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

/// The type of a given Parameter
///
/// - boolean: The parameter is a boolean choice
/// - choice: The parameter presents a choice between multiple values
/// - string: The parameter is a string parameter
/// - run: The parameter expects the identifier of another build
/// - password: The parameter expects a secure string
/// - file: The parameter expects a filename or a file to be uploaded
/// - textBox: The parameter expects (possibly longer) text
/// - unknown: The parameter is not known at the moment
enum ParameterType: String{
    case boolean = "BooleanParameterDefinition"
    case choice = "ChoiceParameterDefinition"
    case string = "StringParameterDefinition"
    case run = "RunParameterDefinition"
    case password = "PasswordParameterDefinition"
    case file = "FileParameterDefinition"
    case textBox = "TextParameterDefinition"
    case unknown = "Unknown"
    
    /// Get the string that describes the additional data object in the json
    ///
    /// - Returns: The identifying string
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
    
    /// Get the backup default value for a given parameter type, for use when there is no given default value
    ///
    /// - Returns: the backup default value
    func backupDefaultString() -> String?{
        switch self{
            case .boolean: return "\(false)"
            case .string: return ""
            case .textBox: return ""
            default: return nil
        }
    }
    
    init(value: String){
        self = ParameterType(rawValue: value) ?? ParameterType.unknown
    }
}
