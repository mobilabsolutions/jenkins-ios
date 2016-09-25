//
//  AccountManager.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class AccountManager{
    
    static let manager = AccountManager()
    
    /// The list of all accounts
    var accounts: [Account] = []
    
    private init(){}
    
    /// Add an account to the list of available accounts
    ///
    /// - parameter account: The account to add
    func addAccount(account: Account){
        //FIXME: Add the account in a persistent manner
        accounts.append(account)
    }
}
