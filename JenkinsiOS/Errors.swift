//
//  Errors.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

enum NetworkManagerError: Error{
    case JSONParsingFailed
    case HTTPResponseNoSuccess(code: Int, message: String)
    case dataTaskError(nsError: NSError)
    case noDataFound
    case URLBuildingError
    
    var localizedDescription: String{
        switch self {
        case .JSONParsingFailed:
            return "JSON Parsing Failed"
        case .HTTPResponseNoSuccess(let code, let message):
            return message + "\(code)"
        case .dataTaskError(let error):
            return error.localizedDescription
        case .noDataFound:
            return "No data found"
        case .URLBuildingError:
            return "Cannot build url"
        default:
            return "An Error in the NetworkManager occurred"
        }
    }
    
    var code: Int{
        switch self{
            case .JSONParsingFailed: return -2000
            case .HTTPResponseNoSuccess(let code, _): return code
            case .dataTaskError(let error): return error.code
            case .noDataFound: return -3000
            case .URLBuildingError: return -4000
        }
    }
}

enum BuildError: Error{
    case notEnoughDataError
    
    var localizedDescription: String{
        switch self{
            case .notEnoughDataError: return "Not enough data"
        }
    }
}

enum ParsingError: Error{
    case DataNotCorrectFormatError
    case KeyMissingError(key: String)
    
    var localizedDescription: String{
        switch self {
        case .DataNotCorrectFormatError:
            return "The data is not in a correct format"
        case .KeyMissingError(let key):
            return "The key \(key) is missing in the JSON"
        default:
            return "An error occurred while parsing"
        }
    }
}
