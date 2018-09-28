//
//  JobSorter.swift
//  JenkinsiOS
//
//  Created by Robert on 28.09.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import Foundation

struct JobSorter {
    enum JobSortingOption {
        case date
        case status
        case health
    }

    func sortJobsInPlace(by option: JobSortingOption, views: [View]) {
        for view in views {
            sortView(by: option, view: view)
        }
    }

    private func sortView(by option: JobSortingOption, view: View) {
        view.jobResults.sort(by: { (first, second) -> Bool in
            switch option {
            case .status:
                guard let firstColor = first.color, let secondColor = second.color
                else { return first.color != nil }
                return firstColor < secondColor
            case .health:
                guard let firstHealthReport = first.data.healthReport.first,
                    let secondHealthReport = second.data.healthReport.first
                else { return first.data.healthReport.first != nil }
                return firstHealthReport.score > secondHealthReport.score
            case .date:
                guard let firstDate = first.data.lastBuild?.timeStamp,
                    let secondDate = second.data.lastBuild?.timeStamp
                else { return first.data.lastBuild?.timeStamp != nil }
                // Sort by date closest to now
                return firstDate > secondDate
            }
        })
    }
}

extension JenkinsColor: Comparable {
    static func < (lhs: JenkinsColor, rhs: JenkinsColor) -> Bool {
        return lhs.priorityForColor() > rhs.priorityForColor()
    }

    private func priorityForColor() -> Int {
        switch self {
        case .aborted: fallthrough
        case .abortedAnimated: return 0
        case .disabled: fallthrough
        case .disabledAnimated: return 1
        case .notBuilt: fallthrough
        case .notBuiltAnimated: return 2
        case .red: fallthrough
        case .redAnimated: return 3
        case .yellow: fallthrough
        case .yellowAnimated: return 4
        case .folder: return 5
        case .blue: fallthrough
        case .blueAnimated: return 6
        }
    }
}
