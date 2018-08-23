//
//  FavoriteTableViewCell.swift
//  JenkinsiOSTodayExtension
//
//  Created by Robert on 23.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var favoritable: Favoratible? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.container.layer.cornerRadius = 5
        self.container.backgroundColor = Constants.UI.backgroundColor.withAlphaComponent(0.1)
        self.separator.backgroundColor = self.separator.backgroundColor?.withAlphaComponent(0.1)
        self.contentView.backgroundColor = .clear
        self.nameLabel.textColor = .black
        self.detailLabel.textColor = Constants.UI.greyBlue
    }
    
    private func updateUI() {
        guard let favoritable = favoritable
            else { updateForLoading(); return }
        
        if let job = favoritable as? Job {
            nameLabel.text = job.name
            detailLabel.text = job.healthReport.first?.description
            
            if let color = job.color?.rawValue{
                statusImageView.image = UIImage(named: color + "Circle")
            }
        }
        else if let build = favoritable as? Build {
            nameLabel.text = build.fullDisplayName ?? build.displayName ?? "Build #\(build.number)"
            
            if let duration = build.duration{
                detailLabel.text = build.duration != nil ? "Duration: \(duration.toString())" : nil
            }
            
            if let result = build.result?.lowercased() {
                statusImageView.image = UIImage(named: result + "Circle")
            }
        }
    }
    
    private func updateForLoading() {
        nameLabel.text = "Loading..."
        detailLabel.text = "Loading Favorite"
        statusImageView.image = UIImage(named: "emptyCircle")
        selectionStyle = .none
    }
}
