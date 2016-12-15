//
//  AppearanceManager.swift
//  JenkinsiOS
//
//  Created by Robert on 15.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import  UIKit

class AppearanceManager{
    
    func setGlobalAppearance(){
        manageFonts()
    }
    
    private func manageFonts(){
        
        let fontName = Constants.UI.defaultLabelFont
        
        UILabel.appearance().updateFontName(to: fontName)
        UINavigationBar.appearance().titleTextAttributes = getTitleTextAttributes(font: fontName, qualifier: .bold, size: 20)
        UIBarButtonItem.appearance().setTitleTextAttributes(getTitleTextAttributes(font: fontName, qualifier: .regular, size: 20), for: .normal)
    }
    
    
    private enum FontTypeQualifier: String{
        case regular = "Regular"
        case bold = "Bold"
    }
    
    private func getTitleTextAttributes(font: String, qualifier: FontTypeQualifier, size: CGFloat) -> [String: Any]{
        return [
            NSFontAttributeName : UIFont(name: "\(font)-\(qualifier.rawValue)", size: size) as Any
        ]

    }
}
