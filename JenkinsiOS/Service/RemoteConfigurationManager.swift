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
        private let decoder = JSONDecoder()

        fileprivate init(config: RemoteConfig) {
            self.config = config
        }

        var shouldPresentDisplayNameField: Bool {
            return config[Constants.Identifiers.remoteConfigShowDisplayNameFieldKey].boolValue
        }

        var shouldUseNewAccountDesign: Bool {
            return config[Constants.Identifiers.remoteConfigNewAccountDesignKey].boolValue
        }

        var frequentlyAskedQuestions: [FAQItem] {
            let data = config[Constants.Identifiers.remoteConfigFAQListKey].dataValue
            do {
                return try decoder.decode(Array<FAQItem>.self, from: data)
            } catch _ {
                guard let defaultValue = config.defaultValue(forKey: Constants.Identifiers.remoteConfigFAQListKey,
                                                             namespace: nil)
                else { return [] }

                return (try? decoder.decode(Array<FAQItem>.self, from: defaultValue.dataValue)) ?? []
            }
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
        var defaults = [
            Constants.Identifiers.remoteConfigShowDisplayNameFieldKey: true as NSObject,
            Constants.Identifiers.remoteConfigNewAccountDesignKey: false as NSObject,
        ]

        let faqData = try? JSONEncoder().encode([Constants.Defaults.apiTokenFAQItem])

        if let data = faqData {
            defaults[Constants.Identifiers.remoteConfigFAQListKey] = data as NSData
        }

        config.setDefaults(defaults)
    }

    private func activateConfiguration() {
        print("Activate worked: \(config.activateFetched())")
    }

    private func fetchNewConfiguration() {
        config.fetch()
    }
}
