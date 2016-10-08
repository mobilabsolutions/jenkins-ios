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
    
    /// Add an account to the list of available accounts
    ///
    /// - parameter account: The account to add
    func addAccount(account: Account){
        
        accounts.append(account)
        
        if let username = account.username, let password = account.password{
            SAMKeychain.setPassword(password, forService: "com.mobilabsolutions.jenkins.account", account: username)
        }
        
        var url = Constants.Paths.accountsPath
        
        if !FileManager.default.fileExists(atPath: url.path){
            _ = try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        url.appendPathComponent(account.baseUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)
        
        NSKeyedArchiver.archiveRootObject(account, toFile: url.path)
    }
    
    /// Return the full list of accounts
    ///
    /// - returns: The list of user added accounts
    private func getAccounts() -> [Account]{
        
        var accounts: [Account] = []
        
        // The accounts that are available in our Keychain service. Relevant data here: account, password
        let keychainAccounts = SAMKeychain.accounts(forService: "com.mobilabsolutions.jenkins.account").flatMap { (arr) -> [String: String] in
            // Only the username and password are relevant here, therefore, we flat map
            // the array to a dictionary that maps usernames to passwords
            var returnDict: [String: String]  = [:]
            for entry in arr{
                returnDict[entry["acct"] as! String] = entry["password"] as? String
            }
            return returnDict
        }
        
        let url = Constants.Paths.accountsPath
        
        do{
            let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileUrl in urls{
                if let account = NSKeyedUnarchiver.unarchiveObject(withFile: fileUrl.path) as? Account{
                    
                    if let username = account.username{
                        account.password = keychainAccounts?[username]
                    }
                    
                    accounts.append(account)
                }
            }
        }
        catch{
            print(error)
        }
        return accounts
    }
    
    /// Delete a given account persistently
    ///
    /// - parameter account: The account to delete
    func deleteAccount(account: Account) throws{
        
        let url = Constants.Paths.accountsPath.appendingPathComponent(account.baseUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)
        
        try FileManager.default.removeItem(at: url)
        
        if let username = account.username{
            SAMKeychain.deletePassword(forService: "com.mobilabsolutions.jenkins.account", account: username)
        }
        
        accounts = getAccounts()
    }
}
