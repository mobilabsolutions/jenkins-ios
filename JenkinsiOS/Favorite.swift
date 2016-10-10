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
        case Job = "Job"
        case Build = "Build"
    }
    
    var type: FavoriteType
    var url: URL
    
    init(url: URL, type: FavoriteType){
        self.type = type
        self.url = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let url = aDecoder.decodeObject(forKey: "url") as? URL, let type = aDecoder.decodeObject(forKey: "type") as? String
            else { return nil }
        self.url = url
        self.type = FavoriteType(rawValue: type)!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(type.rawValue, forKey: "type")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let fav = object as? Favorite
            else { return false }
        return fav.url == self.url && fav.type == self.type
    }
}
