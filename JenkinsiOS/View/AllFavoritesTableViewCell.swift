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
    
    enum FavoritesSections: CustomStringConvertible, Equatable {
        var description: String {
            switch self {
            case .job:
                return "JOBS"
            case .build:
                return "BUILDS"
            case .all(let count):
                return "SHOW ALL (\(count))"
            }
        }
        
        case build
        case job
        case all(count: Int)
    }
    
    var currentSectionFilter: FavoritesSections = .all(count: 0) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noFavoritesAvailableLabel: UILabel!
    @IBOutlet weak var noFavoritesAvailableImageView: UIImageView!
    @IBOutlet weak var noFavoritesAvailableDescriptionLabel: UILabel!
    
    var favorites: [Favorite] = [] {
        didSet {
            loadedFavoritables = []
            failedLoads = []
            self.collectionView.reloadData()
            self.loader?.loadFavorites(favorites: favorites)
            self.collectionView.isHidden = favorites.isEmpty
            self.noFavoritesAvailableLabel.isHidden = !favorites.isEmpty
            self.noFavoritesAvailableDescriptionLabel.isHidden = !favorites.isEmpty
            self.noFavoritesAvailableImageView.isHidden = !favorites.isEmpty
            self.currentSectionFilter = .all(count: favorites.count)
        }
    }

    var loader: FavoritesLoader?
    var delegate: AllFavoritesTableViewCellDelegate?

    private var loadedFavoritables: [(favoratible: Favoratible, favorite: Favorite)] = []
    private var failedLoads: [Favorite] = []

    func getFavoritableAndFavoriteForIndexPath(indexPath: IndexPath) -> (Favoratible, Favorite)? {
        switch stateForIndexPath(indexPath: indexPath){
            case .loaded(_):
                return loadedFavoritables.filter({ isOfCurrentFilterType(favorite: $0.favorite) })[indexPath.row]
            case .errored: fallthrough
            case .loading:
                return nil
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.noFavoritesAvailableDescriptionLabel.textColor = Constants.UI.silver
        self.noFavoritesAvailableLabel.textColor = Constants.UI.silver
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.filter(isOfCurrentFilterType).count
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
        switch stateForIndexPath(indexPath: indexPath) {
        case .loading:
            return false
        default:
            return true
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filteredLoaded = loadedFavoritables.filter { isOfCurrentFilterType(favorite: $0.favorite) }
        let filteredFailed = failedLoads.filter(isOfCurrentFilterType)
        let filteredFavoritesCount = favorites.lazy.filter { self.isOfCurrentFilterType(favorite: $0) }.count
        
        switch stateForIndexPath(indexPath: indexPath){
            case .loaded(let favoritable):
                delegate?.didSelectLoadedFavoritable(favoritable: favoritable, for: filteredLoaded[indexPath.row].favorite)
            case .errored:
                let selectedFavorite = filteredFailed[indexPath.row - (filteredFavoritesCount - filteredFailed.count)]
                delegate?.didSelectErroredFavorite(favorite: selectedFavorite)
            default: return
        }
    }

    private func stateForIndexPath(indexPath: IndexPath) -> FavoriteLoadingState {
        let filteredLoaded = loadedFavoritables.filter { isOfCurrentFilterType(favorite: $0.favorite) }
        let filteredFailed = failedLoads.filter(isOfCurrentFilterType)
        let filteredFavoritesCount = favorites.filter(isOfCurrentFilterType).count
        
        if indexPath.item < filteredLoaded.count {
            return .loaded(favoritable: filteredLoaded[indexPath.item].favoratible)
        }
        else if indexPath.item >= filteredFavoritesCount - filteredFailed.count {
            return .errored
        }
        return .loading
    }

    private func isOfCurrentFilterType(favorite: Favorite) -> Bool {
        switch currentSectionFilter {
        case .all(count: _): return true
        case .build: return favorite.type == .build
        case .job: return favorite.type == .job || favorite.type == .folder
        }
    }
    
    func didLoadFavorite(favoritable: Favoratible, from favorite: Favorite) {
        loadedFavoritables.append((favoritable, favorite))
        collectionView.reloadData()
    }

    func didFailToLoad(favorite: Favorite, reason: FavoriteLoadingFailure) {
        failedLoads.append(favorite)
        collectionView.reloadData()
    }
}
