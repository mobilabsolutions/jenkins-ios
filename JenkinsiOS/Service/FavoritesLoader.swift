//
// Created by Robert on 22.06.17.
// Copyright (c) 2017 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol FavoritesLoading: class {
    func didLoadFavorite(favoritable: Favoratible, from favorite: Favorite)
    func didFailToLoad(favorite: Favorite, reason: FavoriteLoadingFailure)
}

enum FavoriteLoadingFailure {
    case noAccount
    case networkManagerError(error: Error)
    case noFavoritableReturned
}

class FavoritesLoader {
    private unowned var delegate: FavoritesLoading

    init(with delegate: FavoritesLoading) {
        self.delegate = delegate
    }

    func loadFavorites(favorites: [Favorite]) {
        for favorite in favorites {
            guard let account = favorite.account
            else { delegate.didFailToLoad(favorite: favorite, reason: .noAccount); continue }
            switch favorite.type {
            case .build:
                loadBuild(favorite: favorite, with: account)
            // Folders are in essence just jobs themselves
            case .job, .folder:
                loadJob(favorite: favorite, with: account)
            }
        }
    }

    private func didLoadFavoritable(favoritable: Favoratible?, error: Error?, for favorite: Favorite) {
        DispatchQueue.main.async {
            guard error == nil
            else {
                self.delegate.didFailToLoad(favorite: favorite,
                                            reason: .networkManagerError(error: error!))
                return
            }

            guard let favoritable = favoritable
            else {
                self.delegate.didFailToLoad(favorite: favorite,
                                            reason: .noFavoritableReturned)
                return
            }

            self.delegate.didLoadFavorite(favoritable: favoritable, from: favorite)
        }
    }

    private func loadJob(favorite: Favorite, with account: Account) {
        let userRequest = UserRequest.userRequestForJob(account: account, requestUrl: favorite.url)
        _ = NetworkManager.manager.getJob(userRequest: userRequest) { job, error in
            self.didLoadFavoritable(favoritable: job, error: error, for: favorite)
        }
    }

    private func loadBuild(favorite: Favorite, with account: Account) {
        let userRequest = UserRequest(requestUrl: favorite.url, account: account)
        _ = NetworkManager.manager.getBuild(userRequest: userRequest) { build, error in
            self.didLoadFavoritable(favoritable: build, error: error, for: favorite)
        }
    }
}
