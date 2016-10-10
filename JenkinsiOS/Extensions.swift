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
                return "nil"
            default:
                return "\(self!)"
        }
    }
}
