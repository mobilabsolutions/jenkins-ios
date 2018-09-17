//
//  AppearanceManager.swift
//  JenkinsiOS
//
//  Created by Robert on 15.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class AppearanceManager {
    func setGlobalAppearance() {
        manageFonts()
    }

    private func manageFonts() {
        let fontName = Constants.UI.defaultLabelFont

        UILabel.appearance().updateFontName(to: fontName)

        var navigationTitleAttributes = getTitleTextAttributes(font: fontName, qualifier: .bold, size: 20)
        navigationTitleAttributes[.foregroundColor] = Constants.UI.greyBlue
        UINavigationBar.appearance().titleTextAttributes = navigationTitleAttributes
        UIBarButtonItem.appearance().setTitleTextAttributes(getTitleTextAttributes(font: fontName, qualifier: .regular, size: 20), for: .normal)
        UINavigationBar.appearance().backgroundColor = Constants.UI.paleGreyColor
        // Remove shadow below UINavigationBar
        UINavigationBar.appearance().shadowImage = UIImage()
    }

    private func getTitleTextAttributes(font: String, qualifier: UIFont.FontTypeQualifier, size: CGFloat) -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont.font(name: font, qualifier: qualifier, size: size) as Any,
        ]
    }
}

extension UIFont {
    static func defaultFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.font(name: Constants.UI.defaultLabelFont, qualifier: .regular, size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func boldDefaultFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.font(name: Constants.UI.defaultLabelFont, qualifier: .bold, size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    fileprivate enum FontTypeQualifier: String {
        case regular = "Regular"
        case bold = "Bold"
    }

    fileprivate static func font(name: String, qualifier: FontTypeQualifier, size: CGFloat) -> UIFont? {
        return UIFont(name: "\(name)-\(qualifier.rawValue)", size: size)
    }
}
