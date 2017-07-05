//
// Created by Robert on 28.06.17.
// Copyright (c) 2017 MobiLab Solutions. All rights reserved.
//

enum FavoriteLoadingState{
    case loaded(favoritable: Favoratible)
    case errored
    case loading
}