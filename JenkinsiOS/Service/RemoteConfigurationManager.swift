//
//  RemoteConfigurationManager.swift
//  JenkinsiOS
//
//  Created by Robert on 04.12.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import Firebase

class RemoteConfigurationManager {
    private let config = RemoteConfig.remoteConfig()

    struct RemoteConfiguration {
        private let config: RemoteConfig

        fileprivate init(config: RemoteConfig) {
            self.config = config
        }

        var shouldPresentDisplayNameField: Bool {
            return config[Constants.Identifiers.remoteConfigShowDisplayNameFieldKey].boolValue
        }

        var shouldUseNewAccountDesign: Bool {
            return config[Constants.Identifiers.remoteConfigNewAccountDesignKey].boolValue
        }
    }

    var configuration: RemoteConfiguration {
        return RemoteConfiguration(config: config)
    }

    func activateRemoteConfiguration() {
        setDefaultValues()
        activateConfiguration()
        fetchNewConfiguration()
    }

    private func setDefaultValues() {
        config.setDefaults([
            Constants.Identifiers.remoteConfigShowDisplayNameFieldKey: true as NSObject,
            Constants.Identifiers.remoteConfigNewAccountDesignKey: false as NSObject,
        ])
    }

    private func activateConfiguration() {
        print("Activate worked: \(config.activateFetched())")
    }

    private func fetchNewConfiguration() {
        config.fetch()
    }
}
