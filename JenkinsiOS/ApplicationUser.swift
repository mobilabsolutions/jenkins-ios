//
//  ApplicationUser.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class ApplicationUser: NSObject, NSCoding{

    var favorites: [Favorite] = []
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let favoritesData = aDecoder.decodeObject(forKey: "favorites") as? [Data]
            else { return nil }
        favorites = favoritesData.map({ (data) -> Favorite in
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! Favorite
        })
    }
    
    func encode(with aCoder: NSCoder) {
        let favoritesData = favorites.map { (favorite) -> Data in
            return NSKeyedArchiver.archivedData(withRootObject: favorite)
        }
        aCoder.encode(favoritesData, forKey: "favorites")
    }
    
}
