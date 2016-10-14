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
    var isFavorite: Bool {get}
    func toggleFavorite(account: Account)
}

extension Favoratible{
    
    private func getType() -> Favorite.FavoriteType?{
        var type: Favorite.FavoriteType? = nil
        
        switch self{
        case is Job:
            type = .job
        case is Build:
            type = .build
        default:
            type = nil
        }
        
        return type
    }
    
    func toggleFavorite(account: Account){
        if let type = getType(){
            if let index = ApplicationUserManager.manager.applicationUser.favorites.index(of: Favorite(url: self.url, type: type, account: account)){
                ApplicationUserManager.manager.applicationUser.favorites.remove(at: index)
            }
            else{
                ApplicationUserManager.manager.applicationUser.favorites.append(Favorite(url: self.url, type: type, account: account))
            }
            
            ApplicationUserManager.manager.save()
        }
    }
    
    var isFavorite: Bool{
        get{
            guard let type = getType()
                else { return false }
            return ApplicationUserManager.manager.applicationUser.favorites.contains(Favorite(url: self.url, type: type, account: nil))
        }
    }
}
