//
//  PerformActionURLSessionDelegate.swift
//  JenkinsiOS
//
//  Created by Robert on 13.11.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import Foundation

class PerformActionURLSessionDelegate: NSObject, URLSessionTaskDelegate {
    var accountForTask: ((URLSessionTask) -> (Account?))?

    func urlSession(_: URLSession, task: URLSessionTask, willPerformHTTPRedirection _: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        guard let account = accountForTask?(task),
            let authValue = NetworkManager.manager.basicAuthenticationHeader(account: account)["Authorization"]
        else { completionHandler(request); return }

        var newRequest = request
        newRequest.setValue(authValue, forHTTPHeaderField: "Authorization")
        completionHandler(newRequest)
    }
}
