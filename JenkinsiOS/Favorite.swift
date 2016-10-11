//
//  Favorite.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Favorite: NSObject, NSCoding{
    
    enum FavoriteType: String{
        case job = "Job"
        case build = "Build"
    }
    
    var type: FavoriteType
    var url: URL
    var account: Account?
    
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
        guard let account = AccountManager.manager.accounts.first(where: {$0.baseUrl == accountUrl})
            else { return nil }
        self.account = account
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(account?.baseUrl, forKey: "accountUrl")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let fav = object as? Favorite
            else { return false }
        return fav.url == self.url && fav.type == self.type
    }
}
