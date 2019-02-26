//
//  FAQItem.swift
//  JenkinsiOS
//
//  Created by Robert on 25.02.19.
//  Copyright © 2019 MobiLab Solutions. All rights reserved.
//

import Foundation

struct FAQItem {
    let key: String
    let question: String
    let url: URL

    init(key: String, question: String, url: URL) {
        self.key = key
        self.question = question
        self.url = url
    }
}

extension FAQItem: Codable {}
