//
//  AccountManager.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation
import SAMKeychain

class AccountManager{
    
    static let manager = AccountManager()
    
    /// The list of all accounts
    var accounts: [Account] = []
    
    private init(){
        accounts = getAccounts()
    }
    
    /// Update the array of accounts
    func update(){
        accounts = getAccounts()
    }
    
    /// Add an account to the list of available accounts
    ///
    /// - parameter account: The account to add
    func addAccount(account: Account){
        accounts.append(account)
        save(account: account)
    }
    
    /// Return the full list of accounts
    ///
    /// - returns: The list of user added accounts
    private func getAccounts() -> [Account]{
        do{
            #if !IS_EXTENSION
                return try getAccounts(path: Constants.Paths.accountsPath)
            #else
                guard let path = Constants.Paths.sharedAccountsPath
                    else { return [] }
                NSKeyedUnarchiver.setClass(Account.self, forClassName: "JenkinsiOS.Account")
                return try getAccounts(path: path)
            #endif
        }
        catch{
            print(error)
            return []
        }
    }
    
    /// Get all accounts for a given path
    ///
    /// - parameter path: The path in which the accounts are persisted
    ///
    /// - throws: A FileManager error
    ///
    /// - returns: An array containing all existing accounts
    private func getAccounts(path: URL) throws -> [Account]{
        var accounts: [Account] = []
    
        let query = SAMKeychainQuery()
        query.service = "com.mobilabsolutions.jenkins.account"
        query.accessGroup = Constants.Config.keychainAccessGroup

        // The accounts that are available in our Keychain service. Relevant data here: account, password        
        let elements = try? query.fetchAll().map { (arr) -> (String, String?) in
            // Only the username and password are relevant here, therefore, we flat map
            // the array to a dictionary that maps usernames to passwords
            query.account = arr["acct"] as? String
            try? query.fetch()
            return (arr["acct"] as! String, query.password)
        }
        
        let keychainAccounts = elements != nil ? Dictionary(elements: elements!) : [:]
        
        let urls = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for fileUrl in urls{
            if let account = NSKeyedUnarchiver.unarchiveObject(withFile: fileUrl.path) as? Account{
                
                if let username = account.username, let password = keychainAccounts[username]{
                    account.password = password
                }
                
                accounts.append(account)
            }
        }
        
        return accounts
    }
    
    /// Persist all accounts to disk
    func save(){
        for account in accounts{
            save(account: account)
        }
    }
    
    /// Persist a given account
    ///
    /// - parameter account: The account that should be saved
    private func save(account: Account){
        
        let query = SAMKeychainQuery()
        query.account = account.username
        query.password = account.password
        query.service = "com.mobilabsolutions.jenkins.account"
        query.accessGroup = Constants.Config.keychainAccessGroup
        
        try? query.save()
        
        var url = Constants.Paths.accountsPath
        
        if !FileManager.default.fileExists(atPath: url.path){
            _ = try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        url.appendPathComponent(encodedUrlPath(for: account.baseUrl)!)
        
        NSKeyedArchiver.archiveRootObject(account, toFile: url.path)
        guard let sharedUrl = Constants.Paths.sharedAccountsPath?.appendingPathComponent(encodedUrlPath(for: account.baseUrl)!)
            else { return }
        
        _ = try? FileManager.default.createDirectory(at: Constants.Paths.sharedAccountsPath!, withIntermediateDirectories: true, attributes: [:])
        
        NSKeyedArchiver.archiveRootObject(account, toFile: sharedUrl.path)
    }
    
    /// Delete a given account persistently
    ///
    /// - parameter account: The account to delete
    func deleteAccount(account: Account) throws{
        
        let url = Constants.Paths.accountsPath.appendingPathComponent(account.baseUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)
        let sharedUrl = Constants.Paths.sharedAccountsPath!.appendingPathComponent(encodedUrlPath(for: account.baseUrl)!)
        
        try FileManager.default.removeItem(at: url)
        try FileManager.default.removeItem(at: sharedUrl)
        
        if let username = account.username{
            let query = SAMKeychainQuery()
            query.account = username
            query.service = "com.mobilabsolutions.jenkins.account"
            query.accessGroup = Constants.Config.keychainAccessGroup
            try query.deleteItem()
        }
        
        accounts = getAccounts()
    }
    
    //MARK: - Helpers
    
    private func encodedUrlPath(for url: URL) -> String?{
        return url.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
    }
}
