//
//  Extensions.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation
import UIKit

extension URL{
    /// Get the current url, replacing its scheme with a given scheme and its port with a given port
    ///
    /// - parameter scheme: The url scheme that should be used (i.e. https)
    /// - parameter port:   The port that should be used (i.e. 443)
    ///
    /// - returns: The given url, with port and scheme replaced 
    func using(scheme: String, at port: Int? = nil) -> URL?{
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.port = port
        components?.scheme = "https"
        return components?.url
    }
}

extension Optional{
    /// Return a nicer version of an optional value string
    ///
    /// - returns: A string describing the optional: either "nil" or its actual value
    func textify() -> String{
        switch self{
            case .none:
                return "Unknown"
            default:
                return "\(self!)"
        }
    }
}

extension TimeInterval{
    
    /// Convert a TimeInterval to a string describing it
    ///
    /// - returns: A string describing the TimeInterval in the form: xx hours
    ///            yy minutes zz seconds
    func toString() -> String{
        let seconds = (self / 1000).truncatingRemainder(dividingBy: 60)
        let minutes = (self / 60000).truncatingRemainder(dividingBy: 60)
        let hours = self / 3600000

        var returnString = ""
        
        if Int(hours) > 0{
            returnString += "\(Int(hours)) hours "
        }
        if Int(minutes) > 0{
            returnString += "\(Int(minutes)) minutes "
        }
        if Int(seconds) > 0{
            returnString += "\(Int(seconds)) seconds"
        }
        
        return returnString
    }
}

extension UIViewController{
    /// Display an error with given title, message, textfields and alert actions
    ///
    /// - parameter title:      The title of the error
    /// - parameter message:    The error message
    /// - parameter textFields: The text fields that should be displayed
    /// - parameter actions:    The actions that should be displayed
    func displayError(title: String, message: String?, textFieldConfigurations: [(UITextField) -> ()], actions: [UIAlertAction]){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { (action) in
            alertController.addAction(action)
        }
        textFieldConfigurations.forEach { (textFieldConfiguration) in
            alertController.addTextField(configurationHandler: textFieldConfiguration)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
