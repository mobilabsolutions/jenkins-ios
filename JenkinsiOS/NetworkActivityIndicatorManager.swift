//
//  NetworkActivityIndicatorManager.swift
//  JenkinsiOS
//
//  Created by Robert on 17.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class NetworkActivityIndicatorManager{
    
    /// The number of outstanding requests
    private var outstandingRequests = 0
    /// The central NetworkActivityIndicatorManager singleton
    static let manager = NetworkActivityIndicatorManager()
    
    private init(){}
    
    /// Set the activity indicator to active or inactive (once there are no outstanding requests)
    ///
    /// - parameter active: Whether or not to set the indicator to active
    func setActivityIndicator(active: Bool){
        outstandingRequests += (active) ? 1 : -1
        if outstandingRequests < 0{
            outstandingRequests = 0
        }
        
        #if !IS_EXTENSION
            UIApplication.shared.isNetworkActivityIndicatorVisible = (outstandingRequests > 0)
        #endif
    }
    
}
