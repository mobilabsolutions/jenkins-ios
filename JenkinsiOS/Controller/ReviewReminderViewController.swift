//
//  ReviewReminderViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 01.12.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol ReviewReminderViewControllerDelegate {
    func stopReminding()
    func review()
    func feedback(feedback: String)
    func minimumNumberOfStarsForReview() -> Int
    func postponeReminder()
}

class ReviewReminderViewController: UIViewController {
    @IBOutlet var reviewDescriptionLabel: UILabel!
    @IBOutlet var centerView: UIView!
    @IBOutlet var reviewButton: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var stopRemindingButton: UIButton!
    @IBOutlet var starRatingView: StarRatingView!
    @IBOutlet var feedbackTextView: UITextView!

    @IBOutlet var buttonsHeightConstraint: NSLayoutConstraint!
    @IBOutlet var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewCompactHeightConstraint: NSLayoutConstraint?
    private var containerViewExpandedHeightConstraint: NSLayoutConstraint?
    @IBOutlet var feedbackTextViewHeightConstraint: NSLayoutConstraint!

    var delegate: ReviewReminderViewControllerDelegate?

    var feedbackPlaceholderText = "Please give us some feedback to improve the app..."

    init() {
        super.init(nibName: "ReviewReminderViewController", bundle: Bundle.main)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        makeViewSeeThrough()

        if let starRatingView = self.centerView.subviews.first as? StarRatingView {
            starRatingView.delegate = self
        }

        setButtons(hidden: true, animated: false)

        setCompactHeightConstraint()
        setExpandedHeightConstraint()

        setHeightConstraint(height: .compact)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registeredTap))
        view.addGestureRecognizer(gestureRecognizer)

        addKeyboardHandling()

        feedbackTextView.delegate = self

        feedbackTextView.layer.borderColor = #colorLiteral(red: 0.9306202061, green: 0.9306202061, blue: 0.9306202061, alpha: 1).cgColor
        feedbackTextView.layer.borderWidth = 0.7

        reviewButton.titleLabel?.minimumScaleFactor = 0.5
        reviewButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    private func addKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func makeViewSeeThrough() {
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.alpha = 1.0
        containerView.isOpaque = true
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        view.isOpaque = true
    }

    fileprivate func setButtons(hidden: Bool, animated: Bool) {
        func setButtons(hidden: Bool) {
            reviewButton.isHidden = hidden
            stopRemindingButton.isHidden = hidden
            reviewButton.isUserInteractionEnabled = !hidden
            stopRemindingButton.isUserInteractionEnabled = !hidden

            buttonsHeightConstraint.constant = hidden ? 0.0 : 30

            setHeightConstraint(height: hidden ? .compact : .normal)
        }

        if animated {
            UIView.animate(withDuration: 20, animations: {
                setButtons(hidden: hidden)
            })
        } else {
            setButtons(hidden: hidden)
        }
    }

    private func containerHeightConstraint(with multiplier: CGFloat) -> NSLayoutConstraint? {
        guard let containerViewHeightConstraint = containerViewHeightConstraint
        else { return nil }

        return NSLayoutConstraint(
            item: containerViewHeightConstraint.firstItem as Any,
            attribute: containerViewHeightConstraint.firstAttribute,
            relatedBy: containerViewHeightConstraint.relation,
            toItem: containerViewHeightConstraint.secondItem,
            attribute: containerViewHeightConstraint.secondAttribute,
            multiplier: multiplier,
            constant: containerViewHeightConstraint.constant
        )
    }

    private func setCompactHeightConstraint() {
        containerViewCompactHeightConstraint = containerHeightConstraint(with: 0.25)
    }

    private func setExpandedHeightConstraint() {
        containerViewExpandedHeightConstraint = containerHeightConstraint(with: 0.4)
    }

    fileprivate enum HeightConstraintType {
        case expanded
        case normal
        case compact
    }

    fileprivate func setHeightConstraint(height: HeightConstraintType) {
        containerViewExpandedHeightConstraint?.isActive = false
        containerViewHeightConstraint?.isActive = false
        containerViewCompactHeightConstraint?.isActive = false
        feedbackTextViewHeightConstraint.constant = 0.0

        switch height {
        case .expanded:
            containerViewExpandedHeightConstraint?.isActive = true
            feedbackTextViewHeightConstraint.constant = 70.0
        case .normal:
            containerViewHeightConstraint?.isActive = true
        case .compact:
            containerViewCompactHeightConstraint?.isActive = true
        }
    }

    @IBAction func stopReminding(_: UIButton) {
        stopReminding()
    }

    @IBAction func review(_: UIButton) {
        guard let delegate = delegate
        else { return }

        if starRatingView.selectedNumberOfStars >= delegate.minimumNumberOfStarsForReview() {
            dismiss(animated: true) {
                self.delegate?.review()
            }
        } else {
            dismiss(animated: true) {
                self.delegate?.feedback(feedback: self.feedbackTextView.text ?? "")
            }
        }
    }

    private func stopReminding() {
        dismiss(animated: true) {
            self.delegate?.stopReminding()
        }
    }

    @objc private func registeredTap(gestureRecognizer: UIGestureRecognizer) {
        guard !feedbackTextView.isFirstResponder
        else { feedbackTextView.resignFirstResponder(); return }

        let locationRelativeToContainer = gestureRecognizer.location(in: containerView)

        guard locationRelativeToContainer.x < 0.0 || locationRelativeToContainer.y < 0.0
        else { return }

        dismiss(animated: true) {
            self.delegate?.postponeReminder()
        }
    }

    func setReviewButtonEnabledIfNecessary() {
        guard feedbackTextViewHeightConstraint.constant > 0.0
        else { reviewButton.isEnabled = true; return }

        reviewButton.isEnabled = !(feedbackTextView.text.isEmpty || feedbackTextView.text == nil || feedbackTextView.textColor != .black)
    }
}

extension ReviewReminderViewController {
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        getYPositionConstraint()?.constant = -(keyboardRect.height / 2)
    }

    @objc func keyboardWillDisappear(notification _: Notification) {
        getYPositionConstraint()?.constant = 0
    }

    private func getYPositionConstraint() -> NSLayoutConstraint? {
        return view.constraints.first { $0.identifier == "containerViewCentering" }
    }
}

extension ReviewReminderViewController: StarRatingViewDelegate {
    func userDidChangeNumberOfStars(to count: Int) {
        setButtons(hidden: false, animated: true)
        if count >= (delegate?.minimumNumberOfStarsForReview() ?? 4) {
            reviewButton.setTitle("Review", for: .normal)
            reviewDescriptionLabel.text = "We're glad that you are enjoying the app.\nPlease consider leaving a review."
            feedbackTextView.resignFirstResponder()
            setHeightConstraint(height: .normal)
        } else {
            reviewButton.setTitle("Send feedback", for: .normal)
            reviewDescriptionLabel.text = "What can we improve to create a better experience for you?\nPlease consider giving us some feedback."
            setHeightConstraint(height: .expanded)
            optionallySetFeedbackPlaceholder()
        }
        reviewDescriptionLabel.textAlignment = .left
        setReviewButtonEnabledIfNecessary()
    }
}

extension ReviewReminderViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        setReviewButtonEnabledIfNecessary()
        guard textView.textColor != .black
        else { return }

        textView.text = nil
        textView.textColor = UIColor.black
    }

    func textViewDidChange(_: UITextView) {
        setReviewButtonEnabledIfNecessary()
    }

    func optionallySetFeedbackPlaceholder() {
        guard feedbackTextView.text == nil || feedbackTextView.text == ""
        else { return }
        feedbackTextView.textColor = .lightGray
        feedbackTextView.text = feedbackPlaceholderText
    }
}
