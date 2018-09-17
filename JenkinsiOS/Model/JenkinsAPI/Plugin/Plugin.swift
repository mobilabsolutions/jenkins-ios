//
//  Plugin.swift
//  JenkinsiOS
//
//  Created by Robert on 06.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class Plugin {
    /// Whether or not the plugin is active
    var active: Bool
    /// Whether or not the plugin is bundled
    var bundled: Bool?
    /// Whether or not the plugin is deleted
    var deleted: Bool?
    /// Whether or not the plugin is downgradable
    var downgradable: Bool?
    /// Whether or not the plugin is enabled
    var enabled: Bool?
    /// Whether or not the plugin has an update
    var hasUpdate: Bool?
    /// The plugin's long name
    var longName: String?
    /// Whether or not the plugin is pinned
    var pinned: Bool?
    /// The plugin's short name
    var shortName: String
    /// Whether or not the plugin supports dynamic load
    var supportsDynamicLoad: String?
    /// The plugin's url
    var url: URL?
    /// The version of the plugin
    var version: String?
    /// The plugin's dependencies
    var dependencies: [Dependency] = []

    /// Optionally initialize a Plugin
    ///
    /// - parameter json: The json from which to initialize the Plugin
    ///
    /// - returns: The initialized Plugin object or nil, if initialization failed
    init?(json: [String: AnyObject]) {
        guard let active = json[Constants.JSON.active] as? Bool,
            let shortName = json[Constants.JSON.shortName] as? String
        else { return nil }
        self.active = active
        self.shortName = shortName

        bundled = json[Constants.JSON.bundled] as? Bool
        deleted = json[Constants.JSON.deleted] as? Bool
        downgradable = json[Constants.JSON.downgradable] as? Bool
        enabled = json[Constants.JSON.enabled] as? Bool
        hasUpdate = json[Constants.JSON.hasUpdate] as? Bool
        longName = json[Constants.JSON.longName] as? String
        pinned = json[Constants.JSON.pinned] as? Bool
        supportsDynamicLoad = json[Constants.JSON.supportsDynamicLoad] as? String

        if let urlString = json[Constants.JSON.url] as? String {
            url = URL(string: urlString)
        }

        version = json[Constants.JSON.version] as? String

        if let dependenciesJSON = json[Constants.JSON.dependencies] as? [[String: AnyObject]] {
            for dependecyJSON in dependenciesJSON {
                if let dependency = Dependency(json: dependecyJSON) {
                    dependencies.append(dependency)
                }
            }
        }
    }
}
