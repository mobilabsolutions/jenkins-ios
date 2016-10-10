//
//  Favoratible.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol Favoratible {
    var url: URL{get}
    var isFavorite: Bool {get set}
}

extension Favoratible{
    
    private func getType() -> Favorite.FavoriteType?{
        var type: Favorite.FavoriteType? = nil
        
        switch self{
        case is Job:
            type = .Job
        case is Build:
            type = .Build
        default:
            type = nil
        }
        
        return type
    }
    
    var isFavorite: Bool{
        get{
            guard let type = getType()
                else { return false }
            return ApplicationUserManager.manager.applicationUser.favorites.contains(Favorite(url: self.url, type: type))
        }
        set{
            if let type = getType(){
                if !newValue, let index = ApplicationUserManager.manager.applicationUser.favorites.index(of: Favorite(url: self.url, type: type)){
                    ApplicationUserManager.manager.applicationUser.favorites.remove(at: index)
                }
                else{
                    ApplicationUserManager.manager.applicationUser.favorites.append(Favorite(url: self.url, type: type))
                }
            }
        }
    }
}
