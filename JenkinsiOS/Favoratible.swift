//
//  Favoratible.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol Favoratible {
    func favorite()
    var url: URL{get}
}

extension Favoratible{
    func favorite(){
        
        var type: Favorite.FavoriteType? = nil
        
        switch self{
            case is Job:
                type = .Job
            case is Build:
                type = .Build
            default:
                type = nil
        }
        if let type = type{
            ApplicationUser.shared.favorites.append(Favorite(url: self.url, type: type))
        }
    }
}
