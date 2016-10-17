//
//  NetworkActivityIndicatorManager.swift
//  JenkinsiOS
//
//  Created by Robert on 17.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class NetworkActivityIndicatorManager{
    
    private var outstandingRequests = 0
    static let manager = NetworkActivityIndicatorManager()
    
    private init(){}
    
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
