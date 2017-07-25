//
//  BuildProvidable.swift
//  JenkinsiOS
//
//  Created by Robert on 22.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol BuildProvidable {
    func setBuilds(builds: [Build], specialBuilds: [(String, Build)])
    var buildsAlreadyLoaded: Bool { get set }
}
