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

    fileprivate var documentPickerToParameter: [Int: Parameter] = [:]
    fileprivate var parameterValues: [ParameterValue] = []

    @IBOutlet var buildButton: BigButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        parameterValues = parameters.filter { $0.type != .unknown }.map({ ParameterValue(parameter: $0, value: $0.defaultParameterString) })

        loadRunParameterPossibilities(for: parameterValues)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        tableView.keyboardDismissMode = .onDrag

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        title = "Parameters"

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

    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
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

    private func updateButton() {
        buildButton.isEnabled = parameters.isEmpty || parameterValues.reduce(true) { $0 && $1.value != nil }
    }

    private func loadRunParameterPossibilities(for parameters: [ParameterValue]) {
        let runParametersToLoad = parameters.enumerated()
            .filter({ $0.element.parameter.type == .run && $0.element.parameter.additionalData is String })

        for (row, runParameter) in runParametersToLoad {
            delegate?.completeBuildIdsForRunParameter(parameter: runParameter.parameter, completion: { [weak self] parameter in
                DispatchQueue.main.async {
                    runParameter.parameter = parameter
                    self?.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                }
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return parameters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.parameterCell, for: indexPath) as? ParameterTableViewCell
        else { fatalError("Cannot dequeue cell of type ParameterTableViewCell for ParametersTableViewController") }

        cell.parameter = parameters[indexPath.row]
        cell.parameterValue = parameterValues.first(where: { $0.parameter == parameters[indexPath.row] })
        cell.delegate = self

        return cell
    }
}

extension ParametersTableViewController: ParameterTableViewCellDelegate {
    func set(value: String?, for parameter: Parameter) {
        parameterValues.first(where: { $0.parameter.hashValue == parameter.hashValue })?.value = value
        updateButton()
    }

    func openFile(for parameter: Parameter) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPicker.delegate = self
        documentPickerToParameter[documentPicker.hash] = parameter
        present(documentPicker, animated: true, completion: nil)
    }
}

extension ParametersTableViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        didPickDocument(controller: controller, url: url)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first
        else { return }
        didPickDocument(controller: controller, url: url)
    }

    private func didPickDocument(controller: UIDocumentPickerViewController, url: URL) {
        guard let parameter = documentPickerToParameter[controller.hash]
        else { return }
        parameterValues.first(where: { $0.parameter == parameter })?.value = url.path

        if let firstIndex = parameters.firstIndex(where: { $0 == parameter }) {
            tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0)], with: .automatic)
        }

        updateButton()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        documentPickerToParameter[controller.hash] = nil
    }
}
