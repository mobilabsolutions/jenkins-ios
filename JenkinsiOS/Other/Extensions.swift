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
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.port = port
        components?.scheme = scheme
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

extension Bool{
    var humanReadableString: String{
        return self ? "Yes" : "No"
    }
}

extension Double {
    /// Return a string indicating the number of gigabytes from a Double indicating a number of bytes
    ///
    /// - parameter numberFormatter: The numberformatter that should be used
    ///
    /// - returns: The string indicating the number of gigabytes
    func bytesToGigabytesString(numberFormatter: NumberFormatter) -> String{
        return NSNumber(value: self).bytesToGigabytesString(numberFormatter: numberFormatter)
    }
}

extension Int64 {
    /// Return a string indicating the number of gigabytes from an Int64 indicating a number of bytes
    ///
    /// - parameter numberFormatter: The numberformatter that should be used
    ///
    /// - returns: The string indicating the number of gigabytes
    func bytesToGigabytesString(numberFormatter: NumberFormatter) -> String{
        return NSNumber(value: self).bytesToGigabytesString(numberFormatter: numberFormatter)
    }
}

extension NSNumber {
    func bytesToGigabytesString(numberFormatter: NumberFormatter) -> String{
        
        func numberString(from number: Double) -> String?{
            guard number >= 0.0, let str = numberFormatter.string(from: NSNumber(value: number))
                else { return nil }
            return str
        }
        
        func numberString(str: String?, with suffix: String) -> String{
            guard let str = str
                else { return "Unknown" }
            return "\(str) \(suffix)"
        }
        
        if Double(self.int64Value / (1024 * 1024 * 1024)) > 0.5{
            return numberString(str: numberString(from: Double(self.int64Value / (1024 * 1024 * 1024))), with: "GB")
        }
        else if Double(self.int64Value / (1024 * 1024)) > 0.5{
            return numberString(str: numberString(from: Double(self.int64Value / (1024 * 1024))), with: "MB")
        }
        else if Double(self.int64Value / (1024)) > 0.5{
            return numberString(str: numberString(from: Double(self.int64Value / (1024))), with: "KB")
        }
        else{
            return numberString(str: numberString(from: self.doubleValue), with: "B")
        }
    }
}

extension Dictionary {
    /// Instantiate a Dictionary from an array of tuples
    ///
    /// - parameter elements: The array of tuples that the Dictionary should be initialised from
    ///
    /// - returns: An initialised Dictionary object
    init(elements: [(Key, Value)]){
        self.init()
        for (key, value) in elements{
            self[key] = value
        }
    }
}

extension TimeInterval {
    
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
        if Int(minutes) > 0 {
            returnString += "\(Int(minutes)) minutes "
        }
        if Int(seconds) > 0 && !(Int(hours) > 0 && Int(minutes) > 0) {
            returnString += "\(Int(seconds)) seconds"
        }
        
        return returnString.isEmpty ? "Unknown" : returnString
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
        
        // Is the view controller currently visible?
        guard self.isViewLoaded && view.window != nil
            else { return }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { (action) in
            alertController.addAction(action)
        }
        textFieldConfigurations.forEach { (textFieldConfiguration) in
            alertController.addTextField(configurationHandler: textFieldConfiguration)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Display an error based on a given error
    ///
    /// - parameter error:      The error that should be displayed accordingly
    /// - parameter completion: The completion that is called if the error is a 403 NetworkManagerError.HTTPResponseNoSuccess error
    func displayNetworkError(error: Error, onReturnWithTextFields completion: (([String: String?]) -> ())?){
        
        if let networkManagerError = error as? NetworkManagerError{
            switch networkManagerError{
                case .HTTPResponseNoSuccess(let code, _):
                    if code == 403 || code == 401{
                        var userNameTextField: UITextField!
                        var passwordTextField: UITextField!
                        
                        
                        let textFieldConfigurations: [(UITextField) -> ()] = [
                            {
                                (textField) -> () in
                                textField.placeholder = "Username"
                                userNameTextField = textField
                            },
                            {
                                (textField) -> () in
                                textField.placeholder = "Password"
                                passwordTextField = textField
                            }
                        ]
                        
                        let doneAction = UIAlertAction(title: "Save", style: .default){ (_) -> () in
                            completion?(["username" : userNameTextField.text, "password" : passwordTextField.text])
                        }
                        let cancelAction = UIAlertAction(title: "Discard", style: .cancel, handler: nil)
                        
                        let message = "Please provide username and password"
                        
                        displayError(title: "Error", message: message, textFieldConfigurations: textFieldConfigurations, actions: [cancelAction, doneAction])
                    }
                    else{
                        let message = "An error occured \(code)"
                        let cancelAction = UIAlertAction(title: "Alright", style: .cancel, handler: nil)
                        displayError(title: "Error", message: message, textFieldConfigurations: [], actions: [cancelAction])
                    }
                
                case .dataTaskError(let error):
                    let doneAction = UIAlertAction(title: "Alright", style: .cancel, handler: nil)
                    displayError(title: "Error", message: error.localizedDescription, textFieldConfigurations: [], actions: [doneAction])
    
                default:
                    let doneAction = UIAlertAction(title: "Alright", style: .cancel, handler: nil)
                    displayError(title: "Error", message: "An error occurred", textFieldConfigurations: [], actions: [doneAction])
            }
        }
        else{
            let doneAction = UIAlertAction(title: "Alright", style: .cancel, handler: nil)
            displayError(title: "Error", message: error.localizedDescription, textFieldConfigurations: [], actions: [doneAction])
        }
    }
}

extension UIImageView{
    /// Set an image view's image to an image, resized by a scale factor
    ///
    /// - parameter image: The image that should be resized and set as the view's image
    /// - parameter size: The size the image should be resized to
    func withResized(image: UIImage, size: CGSize){

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = newImage
    }
}

extension UILabel{
    func updateFontName(to name: String){
        let fontName =  self.font.isBold ? (name + "-Bold") : name + "-Regular"
        self.font = UIFont(name: fontName, size: self.font.pointSize)
    }
}

extension UIFont{
    var isBold: Bool{
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
}
