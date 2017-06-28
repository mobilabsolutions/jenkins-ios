//
//  AllFavoritesTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 22.06.17.
//  Copyright © 2017 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol AllFavoritesTableViewCellDelegate{
    func didSelectErroredFavorite(favorite: Favorite)
    func didSelectLoadedFavoritable(favoritable: Favoratible, for favorite: Favorite)
}

class AllFavoritesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, FavoritesLoading {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var favorites: [Favorite] = [] {
        didSet{
            loadedFavoritables = []
            failedLoads = []
            self.collectionView.reloadData()
            self.loader?.loadFavorites(favorites: favorites)
        }
    }

    var loader: FavoritesLoader?
    var delegate: AllFavoritesTableViewCellDelegate?

    private var loadedFavoritables: [(favoratible: Favoratible, favorite: Favorite)] = []
    private var failedLoads: [Favorite] = []

    func getFavoritableAndFavoriteForIndexPath(indexPath: IndexPath) -> (Favoratible, Favorite)?{
        switch stateForIndexPath(indexPath: indexPath){
            case .loaded(_):
                return loadedFavoritables[indexPath.row]
            case .errored: fallthrough
            case .loading:
                return nil
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.favoritesCell,
                for: indexPath) as! FavoriteCollectionViewCell

        switch stateForIndexPath(indexPath: indexPath){
            case .loaded(let favoritable):
                cell.favoritable = favoritable
            case .errored:
                cell.setErrored()
            case .loading:
                cell.setLoading()
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if case let .loading(_) = stateForIndexPath(indexPath: indexPath){
            return false
        }
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch stateForIndexPath(indexPath: indexPath){
            case .loaded(let favoritable):
                delegate?.didSelectLoadedFavoritable(favoritable: favoritable, for: loadedFavoritables[indexPath.row].favorite)
            case .errored:
                let selectedFavorite = failedLoads[indexPath.row - (favorites.count - failedLoads.count)]
                delegate?.didSelectErroredFavorite(favorite: selectedFavorite)
            default: return
        }
    }

    private func stateForIndexPath(indexPath: IndexPath) -> FavoriteLoadingState{
        if indexPath.item < loadedFavoritables.count{
            return .loaded(favoritable: loadedFavoritables[indexPath.item].favoratible)
        }
        else if indexPath.item >= favorites.count - failedLoads.count{
            return .errored
        }
        return .loading
    }

    func didLoadFavorite(favoritable: Favoratible, from favorite: Favorite) {
        loadedFavoritables.append((favoritable, favorite))
        collectionView.reloadItems(at: [IndexPath(item: loadedFavoritables.count - 1, section: 0)])
    }

    func didFailToLoad(favorite: Favorite, reason: FavoriteLoadingFailure) {
        failedLoads.append(favorite)
        collectionView.reloadItems(at: [IndexPath(item: favorites.count - failedLoads.count, section: 0)])
    }
}
