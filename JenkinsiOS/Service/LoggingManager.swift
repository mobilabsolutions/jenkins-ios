//
// Created by Robert on 07.02.17.
// Copyright (c) 2017 MobiLab Solutions. All rights reserved.
//

import FirebaseAnalytics
import Foundation

class LoggingManager {
    static let loggingManager = LoggingManager()

    func log(contentView: LoggableContentView) {
        switch contentView {
        case .job: logJobView()
        case .build: logBuildView()
        case .jobList: logJobListView()
        case .buildList: logBuildListView()
        case .buildQueue: logBuildQueueView()
        case .nodes: logNodesView()
        }
    }

    func logJobView() {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [AnalyticsParameterContentType: "job"])
    }

    func logJobListView() {
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: [AnalyticsParameterContentType: "job_list"])
    }

    func logBuildListView() {
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: [AnalyticsParameterContentType: "build_list"])
    }

    func logBuildView() {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [AnalyticsParameterContentType: "build"])
    }

    func logBuildQueueView() {
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: [AnalyticsParameterContentType: "build_queue"])
    }

    func logNodesView() {
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: [AnalyticsParameterContentType: "nodes_list"])
    }

    func logAccountCreation(https: Bool, allowsEveryCertificate: Bool) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: ["https_enabled": https, "all_certs": allowsEveryCertificate])
    }

    func logfavoritedFavoritable(type: Favorite.FavoriteType) {
        Analytics.logEvent("favorited_item", parameters: ["item_type": type.rawValue])
    }

    func logunfavoritedFavoritable(type: Favorite.FavoriteType) {
        Analytics.logEvent("unfavorited_item", parameters: ["item_type": type.rawValue])
    }

    func logTriggeredBuild(withParameters parameters: [ParameterType]) {
        Analytics.logEvent("triggered_build", parameters: ["parameter_types": parameters.map { $0.rawValue }])
    }

    func logTriggeredAction(action: JenkinsAction) {
        Analytics.logEvent("triggered_action", parameters: ["action_type": action.apiConstant()])
    }
}
