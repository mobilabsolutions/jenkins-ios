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

extension UIColor{
    /// Get the corresponding UIColor from a given JenkinsColor
    ///
    /// - parameter jenkinsColor: The Jenkins Color whose UIColor should be determined
    ///
    /// - returns: The UIColor that corresponds to the given JenkinsColor
    static func from(jenkinsColor color: JenkinsColor) -> UIColor{
        return Constants.Colors.jenkinsColors[color] ?? UIColor.clear
    }
}
