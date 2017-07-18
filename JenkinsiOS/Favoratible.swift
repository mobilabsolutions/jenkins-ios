//
//  Favoratible.swift
//  JenkinsiOS
//
//  Created by Robert on 01.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

/// A protocol describing those objects that can be favorites
protocol Favoratible {
    var url: URL{get}
    var isFavorite: Bool {get}
    func toggleFavorite(account: Account)
}

extension Favoratible{
    
    /// Get the type of a given favoritable
    ///
    /// - returns: The type of the favoritable
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
    
    /// Set the Favoritable to favorite if it isn't, else set it to not favorite
    ///
    /// - parameter account: The account that is associated with the favorite
    func toggleFavorite(account: Account){
        if let type = getType(){
            if let index = ApplicationUserManager.manager.applicationUser.favorites.index(of: Favorite(url: self.url, type: type, account: account)){
                ApplicationUserManager.manager.applicationUser.favorites.remove(at: index)
                LoggingManager.loggingManager.logunfavoritedFavoritable(type: type)
            }
            else{
                ApplicationUserManager.manager.applicationUser.favorites.append(Favorite(url: self.url, type: type, account: account))
                LoggingManager.loggingManager.logfavoritedFavoritable(type: type)
            }
            
            ApplicationUserManager.manager.save()
        }
    }
    
    /// A flag indicating whether or not the current favoritable is a favorite
    var isFavorite: Bool{
        get{
            guard let type = getType()
                else { return false }
            return ApplicationUserManager.manager.applicationUser.favorites.contains(Favorite(url: self.url, type: type, account: nil))
        }
    }
}
