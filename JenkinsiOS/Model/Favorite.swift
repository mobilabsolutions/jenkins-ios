//
//  Favorite.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Favorite: NSObject, NSCoding{
    
    /// An enum describing the type of a favorite
    ///
    /// - job:   The favorite is a job
    /// - build: The favorite is a build
    enum FavoriteType: String{
        case job = "Job"
        case build = "Build"
        case folder = "Folder"
    }
    
    /// The type of the Favorite
    var type: FavoriteType
    /// The url that the favorite is associated with
    var url: URL
    /// The account that the account is associated with
    var account: Account?
    
    /// Initialize a Favorite
    ///
    /// - parameter url:     The url that the favorite should be associated with
    /// - parameter type:    The favorite's type
    /// - parameter account: The account associated with the favorite
    ///
    /// - returns: An initialized Favorite object 
    init(url: URL, type: FavoriteType, account: Account?){
        self.type = type
        self.url = url
        self.account = account
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let url = aDecoder.decodeObject(forKey: "url") as? URL, let type = aDecoder.decodeObject(forKey: "type") as? String, let accountUrl = aDecoder.decodeObject(forKey: "accountUrl") as? URL
            else { return nil }
        self.url = url
        self.type = FavoriteType(rawValue: type)!
        AccountManager.manager.update()
        self.account = AccountManager.manager.accounts.first(where: {$0.baseUrl == accountUrl})
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(account?.baseUrl, forKey: "accountUrl")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let fav = object as? Favorite
            else { return false }
        return (fav.url == self.url) && (fav.type == self.type)
    }
}
