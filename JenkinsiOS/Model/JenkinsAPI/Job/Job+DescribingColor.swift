//
// Created by Robert on 27.06.17.
// Copyright (c) 2017 MobiLab Solutions. All rights reserved.
//

import UIKit

extension Job: DescribingColor{
    func describingColor() -> UIColor{
        guard let color = self.color
                else { return .clear }
        switch color{
            case .aborted: fallthrough
            case .abortedAnimated:
                return UIColor(red: 159/255, green: 159/255, blue: 159/255, alpha: 1.0)
            case .blue: fallthrough
            case .blueAnimated:
                return UIColor(red: 22/255, green: 91/255, blue: 244/255, alpha: 1.0)
            case .red: fallthrough
            case .redAnimated:
                return UIColor(red: 238/255, green: 0, blue: 0, alpha: 1.0)
            case .disabled: fallthrough
            case .disabledAnimated:
                return UIColor(red: 82/255, green: 81/255, blue: 82/255, alpha: 1.0)
            case .folder:
                return UIColor.blue.withAlphaComponent(0.5)
            case .notBuilt: fallthrough
            case .notBuiltAnimated:
                return UIColor(red: 237/255, green: 160/255, blue: 0, alpha: 1.0)
            case .yellow: fallthrough
            case .yellowAnimated:
                return UIColor(red: 255/255, green: 222/255, blue: 44/255, alpha: 1.0)
        }
    }
}
