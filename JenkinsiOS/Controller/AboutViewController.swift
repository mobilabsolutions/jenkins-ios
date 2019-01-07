//
//  AboutViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 31.12.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import MessageUI
import UIKit

class AboutViewController: UIViewController {
    @IBOutlet private var versionLabel: UILabel!
    @IBOutlet private var giveFeedbackButton: BigButton!
    @IBOutlet private var rateButton: BigButton!
    @IBOutlet var aboutLabel: UILabel!

    private let versionBuilder = VersionNumberBuilder()
    private let aboutText = "Butler Client For Jenkins is the best Jenkins CI client for iOS. Its simple design, as well as feature richness, make it the perfect companion for your Jenkins server.\nButler was designed with the last generation of iOS in mind."

    override func viewDidLoad() {
        super.viewDidLoad()
        if let version = versionBuilder.versionNumber {
            versionLabel.text = "Butler v\(version)"
        } else {
            versionLabel.text = "Butler"
        }

        giveFeedbackButton.backgroundColor = Constants.UI.greyBlue

        rateButton.addTarget(self, action: #selector(rate), for: .touchUpInside)
        giveFeedbackButton.addTarget(self, action: #selector(giveFeedback), for: .touchUpInside)

        aboutLabel.text = aboutText
    }

    @objc private func rate() {
        let reviewHandler = ReviewHandler(presentOn: self)
        reviewHandler.triggerReview()
    }

    @objc private func giveFeedback() {
        guard MFMailComposeViewController.canSendMail()
        else { presentMailNotPossibleError(); return }

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["jenkinsios@mobilabsolutions.com"])

        let subject: String

        if let version = versionBuilder.versionNumber {
            subject = "Feedback Butler iOS v\(version)"
        } else {
            subject = "Feedback Butler iOS"
        }

        mail.setSubject(subject)
        present(mail, animated: true, completion: nil)
    }

    private func presentMailNotPossibleError() {
        displayError(title: "Mail not setup", message: "Cannot send feedback when Mail is not setup.", textFieldConfigurations: [], actions: [
            UIAlertAction(title: "OK", style: .default, handler: nil),
        ])
    }
}

extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
