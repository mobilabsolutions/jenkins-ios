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
    /// - parameter completion: A closure that handles the (optional) job list and the (optional) Error
    func getJobs(userRequest: UserRequest, completion: @escaping (JobList?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else {
                    completion(nil, error)
                    return
                }
            guard let data = data
                else{ completion(nil, NetworkManagerError.noDataFound); return }
            
            do{
                guard let jobListJson = data as? [String: AnyObject]
                    else { throw ParsingError.DataNotCorrectFormatError }
                let jobList = try JobList(json: jobListJson)
                completion(jobList, nil)
            }
            catch{
                completion(nil, error)
            }
        }
    }
    
    /// Get a job from a given user request
    ///
    /// - parameter userRequest: The user request containing the job url
    /// - parameter completion:  A closure handling the (optional) Job and an (optional) error
    func getJob(userRequest: UserRequest, completion: @escaping (Job?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else {
                    completion(nil, error)
                    return
            }
            guard let data = data
                else{ completion(nil, NetworkManagerError.noDataFound); return }
            
            do{
                guard let jobJson = data as? [String: AnyObject]
                    else { throw ParsingError.DataNotCorrectFormatError }
                guard let job = Job(json: jobJson, minimalVersion: false)
                    else { throw ParsingError.DataNotCorrectFormatError }
                completion(job, nil)
            }
            catch{
                completion(nil, error)
            }
        }
    }

    /// Get a build from a given user request
    ///
    /// - parameter userRequest: The user request containing the build url
    /// - parameter completion:  A closure handling the (optional) Build and an (optional) error
    func getBuild(userRequest: UserRequest, completion: @escaping (Build?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else {
                    completion(nil, error)
                    return
            }
            guard let data = data
                else{ completion(nil, NetworkManagerError.noDataFound); return }
            
            do{
                guard let buildJson = data as? [String: AnyObject]
                    else { throw ParsingError.DataNotCorrectFormatError }
                guard let build = Build(json: buildJson, minimalVersion: false)
                    else { throw ParsingError.DataNotCorrectFormatError }
                completion(build, nil)
            }
            catch{
                completion(nil, error)
            }
        }
    }

    
    /// Get the build queue for the given user request
    ///
    /// - parameter userRequest: The user request contaning the build queue url
    /// - parameter completion:  A closure handling the (optional) build queue and an (optional) error
    func getBuildQueue(userRequest: UserRequest, completion: @escaping (BuildQueue?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else {
                    completion(nil, error)
                    return
            }
            guard let data = data
                else{ completion(nil, NetworkManagerError.noDataFound); return }
            
            do{
                guard let buildQueueJson = data as? [String: AnyObject]
                    else { throw ParsingError.DataNotCorrectFormatError }
                
                guard let buildQueue = BuildQueue(json: buildQueueJson)
                    else { throw ParsingError.DataNotCorrectFormatError }
                completion(buildQueue, nil)
            }
            catch{
                completion(nil, error)
            }
        }
    }

    
    /// Complete the information for a given job
    ///
    /// - parameter userRequest: The user request fitting for the given job
    /// - parameter job:         The job whose fields should be completed
    /// - parameter completion:  A closure that handles the job and an (optional) error
    func completeJobInformation(userRequest: UserRequest, job: Job, completion: @escaping (Job, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else { completion(job, error); return }
            guard let data = data
                else { completion(job, NetworkManagerError.noDataFound); return }
            guard let json = data as? [String: AnyObject]
                else { completion(job, NetworkManagerError.JSONParsingFailed); return }
            job.addAdditionalFields(from: json)
            completion(job, nil)
        }
    }
    
    /// Complete the information for a given build
    ///
    /// - parameter userRequest: The user request fitting for the current build
    /// - parameter build:       The build whose fields should be completed
    /// - parameter completion:  A closure handling the build and an (optional) error
    func completeBuildInformation(userRequest: UserRequest, build: Build, completion: @escaping (Build, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else { completion(build, error); return }
            guard let data = data
                else { completion(build, NetworkManagerError.noDataFound); return }
            guard let json = data as? [String: AnyObject]
                else { completion(build, NetworkManagerError.JSONParsingFailed); return }
            build.addAdditionalFields(from: json)
            completion(build, nil)
        }
    }
    
    /// Get the test results for a given userRequest
    ///
    /// - parameter userRequest: The user request containing the test result url
    /// - parameter completion:  A closure handling the (optional) TestResult and an (optional) Error
    func getTestResult(userRequest: UserRequest, completion: @escaping (TestResult?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else { completion(nil, error); return }
            guard let data = data
                else { completion(nil, NetworkManagerError.noDataFound); return }
            guard let json = data as? [String: AnyObject]
                else { completion(nil, NetworkManagerError.JSONParsingFailed); return }
            completion(TestResult(json: json), nil)
        }
    }
    
    /// Get the list of computers for a given url
    ///
    /// - parameter userRequest: The user request including url, etc.
    /// - parameter completion:  A closure handling the (optional) computer list and (optional) error
    func getComputerList(userRequest: UserRequest, completion: @escaping (ComputerList?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else { completion(nil, error); return }
            guard let data = data
                else { completion(nil, NetworkManagerError.noDataFound); return }
            guard let json = data as? [String: AnyObject]
                else { completion(nil, NetworkManagerError.JSONParsingFailed); return }
            let computerList = ComputerList(json: json)
            completion(computerList, nil)
        }
    }
    
    /// Get the list of plugins for a given url
    ///
    /// - parameter userRequest: The user request including the url, etc.
    /// - parameter completion:  A closure handling the (optional) plugin list and (optional) error
    func getPlugins(userRequest: UserRequest, completion: @escaping (PluginList?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else { completion(nil, error); return }
            guard let data = data
                else { completion(nil, NetworkManagerError.noDataFound); return }
            guard let json = data as? [String: AnyObject]
                else { completion(nil, NetworkManagerError.JSONParsingFailed); return }
            let pluginList = PluginList(json: json)
            completion(pluginList, nil)

        }
    }
    
    /// Get the list of users for a given url
    ///
    /// - parameter userRequest: The user request including the url, etc
    /// - parameter completion:  A closure handling the (optional) user list and an (optional) error
    func getUsers(userRequest: UserRequest, completion: @escaping (UserList?, Error?) -> ()){
        performRequestForJson(userRequest: userRequest, method: .GET) { (data, error) in
            guard error == nil
                else { completion(nil, error); return }
            guard let data = data
                else { completion(nil, NetworkManagerError.noDataFound); return }
            guard let json = data as? [String: AnyObject]
                else { completion(nil, NetworkManagerError.JSONParsingFailed); return }
            let userList = UserList(json: json)
            completion(userList, nil)
        }
    }

    /// Download a given artifact
    ///
    /// - parameter artifact:   The artifact that should be downloaded
    /// - parameter account:    The account the artifact is associated with
    /// - parameter completion: A closure handling the (optionally) returned data as well as an (optional) error
    func downloadArtifact(artifact: Artifact, account: Account, completion: @escaping ((Data?, Error?) -> ())){
        let request = UserRequest(requestUrl: artifact.url, account: account)
        performRequest(userRequest: request, method: .GET, useAPIURL: false, completion: completion)
    }
    
    /// Get the user request for getting the console output of a given build
    ///
    /// - parameter build:   The build to get the console output for
    /// - parameter account: The account that should be used
    ///
    /// - returns: The url request that gets the console output
    func getConsoleOutputUserRequest(build: Build, account: Account) -> URLRequest{
        let userRequest = UserRequest(requestUrl: build.consoleOutputUrl.using(scheme: "https")!, account: account)
        return urlRequest(for: userRequest, useAPIURL: false, method: .GET)
    }
    
    /// Perform a build on a job using jenkins remote access api
    ///
    /// - parameter account:    The user account, which should be used to trigger the build
    /// - parameter job:        The job that should be built
    /// - parameter token:      The user's token that is set up in the job configuration
    /// - parameter parameters: The build's parameters
    /// - parameter completion: A closure handling the returned data and an (optional) error
    func performBuild(account: Account, job: Job, token: String, parameters: [String: AnyObject]?, completion: ((AnyObject?, Error?) -> ())?) throws{
        var components = URLComponents(url: job.url.appendingPathComponent("/build"), resolvingAgainstBaseURL: true)
        
        components?.queryItems = [
                URLQueryItem(name: "token", value: token)
        ]
        
        if let parameters = parameters{
            
            let keyValuePairs = parameters.flatMap({ (key: String, value: AnyObject) -> String in
                return "\(key):\(value)"
            })
            
            components?.queryItems?.append(URLQueryItem(name: "parameter", value: keyValuePairs.joined(separator: ",")))
        }
        
        guard let url = components?.url
            else { completion?(nil, NetworkManagerError.URLBuildingError); return }
        
        let userRequest = UserRequest(requestUrl: url, account: account)
        performRequestForJson(userRequest: userRequest, method: .POST) { (data, error) in
            if error != nil{
                completion?(nil, error)
                return
            }
            else if data == nil{
                completion?(nil, NetworkManagerError.noDataFound)
                return
            }
            
            completion?(data as AnyObject, nil)
        }
    }
    
    //MARK: - Direct networking
    
    /// Perform a request with the given method and, on returned data, call the completion handler with parsed json data or an error
    ///
    /// - parameter userRequest: The user request object that describes the request
    /// - parameter method:      The HTTP Method that should be used
    /// - parameter completion:  The completion handler, that takes optional json data and an optional error object
    private func performRequestForJson(userRequest: UserRequest, method: HTTPMethod, completion: @escaping (Any?, Error?) -> ()){
        performRequest(userRequest: userRequest, method: method, useAPIURL: true) { (data, error) in
            
            guard let data = data, error == nil
                else { completion(nil, error); return }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                else { completion(nil, NetworkManagerError.JSONParsingFailed); return }
            
            completion(json, nil)
        }
    }
    
    /// Perform a request with the given method and return its data and/or error with the completion handler
    ///
    /// - parameter userRequest: The user request object that describes the request that should be made
    /// - parameter method:      The HTTP method that should be used
    /// - parameter useAPIURL:   Whether or not the userRequest's api url should be used
    /// - parameter completion:  A completion handler that takes an optional data and an optional error
    private func performRequest(userRequest: UserRequest, method: HTTPMethod, useAPIURL: Bool, completion: @escaping (Data?, Error?) -> ()){
        
        let request = urlRequest(for: userRequest, useAPIURL: useAPIURL, method: method)
        
        NetworkActivityIndicatorManager.manager.setActivityIndicator(active: true)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            NetworkActivityIndicatorManager.manager.setActivityIndicator(active: false)
            
            guard let data = data, error == nil
                else { completion(nil, error); return }
            
            if let httpResponse = response as? HTTPURLResponse{
                guard httpResponse.statusCode == 200
                    else {
                        completion(nil, NetworkManagerError.HTTPResponseNoSuccess(code: httpResponse.statusCode, message: httpResponse.description))
                        return
                }
            }
            
            completion(data, error)
        }
        
        task.resume()
    }
    
    //MARK: - Helper methods
    
    /// Create a url request from a given user request
    ///
    /// - parameter userRequest: The user request which to transform into a url request
    /// - parameter useAPIURL:   Whether or not to use the api url for the url request
    /// - parameter method:      The HTTP method the request should use
    ///
    /// - returns: The url request created from the inputted user request
    func urlRequest(for userRequest: UserRequest, useAPIURL: Bool, method: HTTPMethod) -> URLRequest{
        var request = URLRequest(url: (useAPIURL) ? userRequest.apiURL : userRequest.requestUrl)
        request.httpMethod = method.rawValue
        
        if let username = userRequest.account.username, let password = userRequest.account.password{
            request.allHTTPHeaderFields = basicAuthenticationHeader(username: username, password: password)
        }
        return request
    }
    
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
