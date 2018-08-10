//
// Created by Robert on 07.02.17.
// Copyright (c) 2017 MobiLab Solutions. All rights reserved.
//

import Foundation
import Crashlytics

class LoggingManager{
    static let loggingManager = LoggingManager()

    func log(contentView: LoggableContentView){
        switch contentView{
            case .job: logJobView()
            case .build: logBuildView()
            case .jobList: logJobListView()
            case .buildList: logBuildListView()
            case .buildQueue: logBuildQueueView()
            case .favorites: logFavoritesView()
        }
    }

    func logJobView(){
        Answers.logContentView(withName: "Job View", contentType: "Job", contentId: "job")
    }

    func logJobListView(){
        Answers.logContentView(withName: "Job List View", contentType: "Joblist", contentId: "joblist")
    }

    func logBuildListView(){
        Answers.logContentView(withName: "Build List View", contentType: "Buildlist", contentId: "buildlist")
    }

    func logBuildView(){
        Answers.logContentView(withName: "Build View", contentType: "Build", contentId: "build")
    }

    func logBuildQueueView(){
        Answers.logContentView(withName: "Build Queue View", contentType: "BuildQueue", contentId: "buildqueue")
    }

    func logFavoritesView(){
        Answers.logContentView(withName: "Favorites View", contentType: "Favorites", contentId: "favorites")
    }

    func logAccountCreation(https: Bool, allowsEveryCertificate: Bool){
        Answers.logCustomEvent(withName: "Account Creation", customAttributes: ["https": "\(https)", "allCerts": "\(allowsEveryCertificate)"])
    }

    func logfavoritedFavoritable(type: Favorite.FavoriteType){
        Answers.logCustomEvent(withName: "Favorited", customAttributes: ["type": type.rawValue])
    }

    func logunfavoritedFavoritable(type: Favorite.FavoriteType){
        Answers.logCustomEvent(withName: "Unfavorited", customAttributes: ["type": type.rawValue])
    }
    
    func logTriggeredBuild(withParameters: Bool){
        Answers.logCustomEvent(withName: "Build Triggered", customAttributes: ["withParameters" : "\(withParameters)"])
    }
    
    func logTriggeredAction(action: JenkinsAction) {
        Answers.logCustomEvent(withName: "Action Triggered", customAttributes: ["type": action.apiConstant()])
    }
}
