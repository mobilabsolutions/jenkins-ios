//
//  AboutInformationManager.swift
//  JenkinsiOS
//
//  Created by Robert on 08.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

class AboutInformationManager {
    func getAboutText() -> String? {
        return getContentsOfURLInBundle(filename: "AboutText", withExtension: nil)
    }

    func getCreditsText() -> String? {
        return getContentsOfURLInBundle(filename: "CreditsText", withExtension: nil)
    }

    private func getContentsOfURLInBundle(filename: String?, withExtension: String?) -> String? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: withExtension)
        else { return nil }

        return try? String(contentsOf: url)
    }
}
