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
        Analytics.logEvent("view_job", parameters: nil)
    }

    func logJobListView() {
        Analytics.logEvent("view_job_list", parameters: nil)
    }

    func logBuildListView() {
        Analytics.logEvent("view_build_list", parameters: nil)
    }

    func logBuildView() {
        Analytics.logEvent("view_build_view", parameters: nil)
    }

    func logBuildQueueView() {
        Analytics.logEvent("view_build_queue", parameters: nil)
    }

    func logNodesView() {
        Analytics.logEvent("view_nodes_list", parameters: nil)
    }

    func logSettingsView(accountsIncluded: Bool) {
        Analytics.logEvent("view_settings", parameters: ["accounts_included": accountsIncluded])
    }

    func logAccountOverviewView() {
        Analytics.logEvent("view_accounts_overview", parameters: nil)
    }

    func logAddAccountView(displayNameHidden: Bool) {
        Analytics.logEvent("view_add_account_view", parameters: ["display_name_hidden": displayNameHidden])
    }

    func logGithubAccountView() {
        Analytics.logEvent("view_add_github_account", parameters: nil)
    }

    func logOpenGithubTokenUrl() {
        Analytics.logEvent("open_github_token_url", parameters: nil)
    }

    func logOpenFavorite() {
        Analytics.logEvent("open_favorite", parameters: nil)
    }

    func logOpenFavoriteFromWidget() {
        Analytics.logEvent("open_favorite_from_widget", parameters: nil)
    }

    func logAccountCreation(https: Bool, allowsEveryCertificate: Bool, github: Bool, displayName: String?) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            "https_enabled": https, "all_certs": allowsEveryCertificate,
            "github": github, "display_name_nil": displayName == nil,
        ])
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

    func logNumberOfAccounts(accounts: Int) {
        Analytics.setUserProperty(String(accounts), forName: "account_number")
    }
}
