//
//  StarRatingView.swift
//  JenkinsiOS
//
//  Created by Robert on 01.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

@IBDesignable class StarRatingView: UIView {
    @IBOutlet var stars: [UIImageView]!

    @IBInspectable var offImage: UIImage?
    @IBInspectable var onImage: UIImage?

    var delegate: StarRatingViewDelegate?

    private(set) var selectedNumberOfStars = 0

    private var view: UIView?

    private func loadFromNib() -> UIView? {
        return UINib(nibName: "StarRatingView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as? UIView
    }

    private func setupWithXIB() {
        view = loadFromNib()

        guard let view = view
        else { return }

        addSubview(view)
        addConstraints(to: view)
    }

    private func addConstraints(to view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    override func layoutSubviews() {
        for starView in stars {
            starView.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            starView.addGestureRecognizer(tapRecognizer)
        }

        selectStars(count: selectedNumberOfStars)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWithXIB()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWithXIB()
    }

    @objc private func tapped(gestureRecognizer: UIGestureRecognizer) {
        guard let star = gestureRecognizer.view as? UIImageView
        else { return }

        guard let index = stars.index(of: star)
        else { return }

        var numberOfStars = index + 1

        if numberOfStars == selectedNumberOfStars {
            // The user tapped on an already selected last star
            numberOfStars -= 1
        }

        delegate?.userDidChangeNumberOfStars(to: numberOfStars)
        selectStars(count: numberOfStars)
    }

    func selectStars(count: Int) {
        selectedNumberOfStars = count

        for (offset, star) in stars.enumerated() {
            star.image = (offset <= (count - 1)) ? onImage : offImage
        }
    }
}
