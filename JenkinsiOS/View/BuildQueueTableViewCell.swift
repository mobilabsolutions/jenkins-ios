//
//  BuildQueueTableViewCell.swift
//  JenkinsiOS
//
//  Created by Robert on 13.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class BuildQueueTableViewCell: JobTableViewCell {
    @IBOutlet var causeLabel: UILabel!
    @IBOutlet var statusViewContainer: UIView!

    var queueItem: QueueItem? {
        didSet {
            updateForQueueItem()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        causeLabel.text = ""
    }

    private func updateForQueueItem() {
        guard let queueItem = queueItem, let task = queueItem.task
        else { return }
        super.setup(with: .job(job: task))
        causeLabel.text = queueItem.why

        arrowView.isHidden = self.queueItem?.task?.wasBuilt == false

        // Extend the top color of the status view's image to fill the cell's height
        if let image = statusView.image, let cropped = image.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: image.size.width / 4, height: image.size.height / 4)) {
            let patternImage = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
            statusViewContainer.backgroundColor = UIColor(patternImage: patternImage)
            statusView.backgroundColor = .white
        }
    }
}
