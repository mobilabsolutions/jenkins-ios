//
//  NetworkManager.swift
//  JenkinsiOS
//
//  Created by Robert on 23.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class NetworkManager{
    static let manager = NetworkManager()
    
    //MARK: - Enumerations
        
    /// An enum describing the available http methods
    ///
    /// - GET:  Standard HTTP GET Method
    /// - POST: Standard HTTP POST Method
    enum HTTPMethod: String{
        case GET = "GET"
        case POST = "POST"
    }
    
    //MARK: - Networking abstractions
    
    /// Get a list of all jobs for the given url
    ///
    /// - parameter userRequest: The user request object including a base url (where base is a specific, however not yet API-ified url), password and username
    /// - parameter completion:
    func getJobs(userRequest: UserRequest, completion: @escaping (JobList?, Error?) -> ()){
        performRequest(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else {
                    completion(nil, error)
                    return
                }
            guard let data = data
                else{ completion(nil, NetworkManagerError.noDataFound); return }
            
            do{
                let jobList = try JobList(data: data)
                completion(jobList, nil)
            }
            catch{
                completion(nil, error)
            }
        }
    }
    
    //MARK: - Direct networking
    
    /// Perform a request with the given method and, on returned data, call the completion handler
    ///
    /// - parameter userRequest: The user request object that describes the request
    /// - parameter method:      The HTTP Method that should be used
    /// - parameter completion:  The completion handler, that takes an optional data and an optional error object
    private func performRequest(userRequest: UserRequest, method: HTTPMethod, completion: @escaping (Any?, Error?) -> ()){
        
        var request = URLRequest(url: userRequest.apiURL)
        request.httpMethod = method.rawValue
        
        if let username = userRequest.username, let password = userRequest.password{
            request.allHTTPHeaderFields = basicAuthenticationHeader(username: username, password: password)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
            guard let data = data, error == nil
                else { completion(nil, error); return }
            
            if let httpResponse = response as? HTTPURLResponse{
                guard httpResponse.statusCode == 200
                    else {
                        completion(nil, NetworkManagerError.HTTPResponseNoSuccess(code: httpResponse.statusCode, message: httpResponse.description))
                        return
                }
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                else { completion(nil, NetworkManagerError.JSONParsingFailed); return }
            
            completion(json, nil)
        }
        
        task.resume()
    }
    
    //MARK: - Helper methods
    
    /// Create an HTTP Basic Authentication Header from a given username and password
    ///
    /// - parameter username: The username
    /// - parameter password: The password
    ///
    /// - returns: The HTTP Basic Authentication Header created from the given username and password using the scheme: 
    /// "Basic " + _base64encode(username + ":" + password)_
    private func basicAuthenticationHeader(username: String, password: String) -> [String: String]{
        return [
            "Authorization" : "Basic " + "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        ]
    }
}
