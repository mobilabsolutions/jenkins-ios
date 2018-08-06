//
// Created by Robert on 27.06.17.
// Copyright (c) 2017 MobiLab Solutions. All rights reserved.
//

import UIKit

extension Build: DescribingColor{
    func describingColor() -> UIColor {
        guard let result = self.result?.lowercased()
                else { return .clear }

        switch result {
            case "aborted": return UIColor(red: 159/255, green: 159/255, blue: 159/255, alpha: 1.0)
            case "failure": return UIColor(red: 238/255, green: 0, blue: 0, alpha: 1.0)
            case "notbuilt": return UIColor(red: 237/255, green: 160/255, blue: 0, alpha: 1.0)
            case "success": return UIColor(red: 113/255, green: 218/255, blue: 142/255, alpha: 1.0)
            case "unstable": return UIColor(red: 255/255, green: 222/255, blue: 44/255, alpha: 1.0)
            default: return .clear
        }
    }
}
