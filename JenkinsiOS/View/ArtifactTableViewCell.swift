//
//  ArtifactTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 13.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class ArtifactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var container: CorneredView!
    @IBOutlet weak var artifactName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artifactName.text = "..."
    }
}
