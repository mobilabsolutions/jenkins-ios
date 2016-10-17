//
//  ApplicationUserManager.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ApplicationUserManager{
    
    private(set) var applicationUser: ApplicationUser
    
    static let manager = ApplicationUserManager()
    
    private init(){
        applicationUser = NSKeyedUnarchiver.unarchiveObject(withFile: Constants.Paths.userPath.path) as? ApplicationUser ?? ApplicationUser()
    }
    
    func update(){
        applicationUser = NSKeyedUnarchiver.unarchiveObject(withFile: Constants.Paths.userPath.path) as? ApplicationUser ?? ApplicationUser()
    }
    
    func save(){
        NSKeyedArchiver.archiveRootObject(applicationUser, toFile: Constants.Paths.userPath.path)
        guard let path = Constants.Paths.sharedUserPath?.path
            else { return }
        
        _ = try? FileManager.default.createDirectory(at: PersistenceUtils.getSharedDirectory()!.appendingPathComponent("Storage", isDirectory: true), withIntermediateDirectories: true, attributes: [:])
        
        NSKeyedArchiver.archiveRootObject(self.applicationUser, toFile: path)
    }
}
