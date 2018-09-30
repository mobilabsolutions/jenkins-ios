//
//  PluginList.swift
//  JenkinsiOS
//
//  Created by Robert on 06.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class PluginList {
    var plugins: [Plugin] = []

    /// Initialize a list of plugins
    ///
    /// - parameter json: The json from which to initialize the PluginList
    ///
    /// - returns: An initialized PluginList object
    init(json: [String: AnyObject]) {
        if let pluginsJSON = json[Constants.JSON.plugins] as? [[String: AnyObject]] {
            for pluginJSON in pluginsJSON {
                if let plugin = Plugin(json: pluginJSON) {
                    plugins.append(plugin)
                }
            }
        }
    }
}
