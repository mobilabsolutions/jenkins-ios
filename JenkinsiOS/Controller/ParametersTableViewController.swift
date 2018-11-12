//
//  ParametersTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 30.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class ParametersTableViewController: UITableViewController {
    var parameters: [Parameter] = []
    var delegate: ParametersViewControllerDelegate?

    fileprivate var parameterValues: [ParameterValue] = []

    @IBOutlet var buildButton: BigButton!

    @IBAction func dismiss(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        parameterValues = parameters.filter { $0.type != .unknown }.map({ ParameterValue(parameter: $0, value: $0.defaultParameterString) })

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        tableView.keyboardDismissMode = .onDrag

        buildButton.addTarget(self, action: #selector(triggerBuild), for: .touchUpInside)
        updateButton()
    }

    @objc private func triggerBuild() {
        buildButton.isEnabled = false

        delegate?.build(parameters: parameterValues, completion: { quietingDown, error in

            DispatchQueue.main.async { [unowned self] in
                if let error = error {
                    self.handleBuildError(error: error)
                } else {
                    self.handleBuildSuccess(quietingDown: quietingDown)
                }
            }
        })
    }

    private func handleBuildSuccess(quietingDown: JobListQuietingDown?) {
        view.endEditing(true)
        if quietingDown?.quietingDown == true {
            displayError(title: "Quieting Down", message: "The server is currently quieting down.\nThe build was added to the queue.", textFieldConfigurations: [], actions: [
                UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                },
            ])
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func handleBuildError(error: Error) {
        buildButton.isEnabled = true
        displayNetworkError(error: error, onReturnWithTextFields: { data in
            self.delegate?.updateAccount(data: data)
            self.triggerBuild()
        })
    }

    func updateButton() {
        buildButton.isEnabled = parameters.isEmpty || parameterValues.reduce(true) { $0 && $1.value != nil }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return parameters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.parameterCell, for: indexPath) as! ParameterTableViewCell

        cell.parameter = parameters[indexPath.row]
        cell.delegate = self

        return cell
    }
}

extension ParametersTableViewController: ParameterTableViewCellDelegate {
    func set(value: String?, for parameter: Parameter) {
        parameterValues.first(where: { $0.parameter.hashValue == parameter.hashValue })?.value = value
        updateButton()
    }
}
