//
//  Constants.swift
//  JenkinsiOS
//
//  Created by Robert on 25.09.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    struct Defaults{
        /// The default port that should be used. 443 because the default protocol is https
        static let defaultPort = 443
    }
    
    struct Paths{
        static let userPath = PersistenceUtils.getDocumentDirectory()!.appendingPathComponent("User")
    }
    
    struct Identifiers{
        static let accountCell = "accountCell"
        static let jobCell = "jobCell"
        static let buildCell = "buildCell"
        
        static let showJobsSegue = "showJobsSegue"
        static let showJobSegue = "showJobSegue"
        static let showBuildsSegue = "showBuildsSegue"
        static let showBuildSegue = "showBuildSegue"
    }
    
    struct Colors{
        static let jenkinsColors: [JenkinsColor: UIColor] = [
            JenkinsColor.blue: UIColor.blue,
            JenkinsColor.red: UIColor.red,
            JenkinsColor.yellow: UIColor.yellow,
            JenkinsColor.disabled: UIColor.lightGray,
            JenkinsColor.aborted: UIColor.darkGray,
            JenkinsColor.notBuilt: UIColor.orange
        ]
    }
}
