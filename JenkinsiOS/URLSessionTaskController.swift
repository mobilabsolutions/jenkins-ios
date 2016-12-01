//
//  URLSessionTaskController.swift
//  JenkinsiOS
//
//  Created by Robert on 01.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

@objc protocol URLSessionTaskControllerDelegate{
    @objc optional func didCancel(task: URLSessionTask)
    @objc optional func didSuspend(task: URLSessionTask)
    @objc optional func didResume(task: URLSessionTask)
}

class URLSessionTaskController{

    var delegate: URLSessionTaskControllerDelegate?
    private var task: URLSessionTask

    init(task: URLSessionTask, delegate: URLSessionTaskControllerDelegate? = nil){
        self.task = task
        self.delegate = delegate
    }
    
    func cancelTask(){
        task.cancel()
        delegate?.didCancel?(task: task)
    }
    
    func suspendTask(){
        task.suspend()
        delegate?.didSuspend?(task: task)
    }
    
    func resumeTask(){
        task.resume()
        delegate?.didResume?(task: task)
    }
}

