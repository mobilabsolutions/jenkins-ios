//
//  FAQTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 25.02.19.
//  Copyright © 2019 MobiLab Solutions. All rights reserved.
//

import SafariServices
import UIKit

class FAQTableViewController: UITableViewController {
    private let remoteConfigManager = RemoteConfigurationManager()
    private var questions: [FAQItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        questions = remoteConfigManager.configuration.frequentlyAskedQuestions
        tableView.backgroundColor = Constants.UI.backgroundColor
        tableView.separatorStyle = .none

        title = "FAQs"
        tableView.contentInset.top = 24
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.faqCell, for: indexPath) as? BasicTableViewCell
        else { fatalError("Could not dequeue cell of type BasicTableViewCell for FAQ table") }
        cell.title = questions[indexPath.row].question
        return cell
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return questions.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = SFSafariViewController(url: questions[indexPath.row].url)
        present(viewController, animated: true, completion: nil)
    }
}
