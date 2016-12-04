//
//  StarRatingViewDelegate.swift
//  JenkinsiOS
//
//  Created by Robert on 04.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation

protocol StarRatingViewDelegate {
    func userDidChangeNumberOfStars(to count: Int)
}
