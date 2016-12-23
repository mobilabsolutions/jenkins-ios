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
    
    @IBOutlet weak var buildButton: BigButton!
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parameterValues = parameters.filter{ $0.type != .unknown }.map({ ParameterValue(parameter: $0, value: $0.defaultParameterString) })
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        tableView.keyboardDismissMode = .onDrag
        
        tableView.tableFooterView = buildButton
        buildButton.addTarget(self, action: #selector(triggerBuild), for: .touchUpInside)
        updateButton()
    }

    @objc private func triggerBuild(){
        buildButton.isEnabled = false
        
        delegate?.build(parameters: parameterValues, completion: { (error) in
            
            DispatchQueue.main.async {
                if error == nil{
                    
                    self.tableView.visibleCells.forEach({ (cell) in
                        cell.subviews.forEach({ (view) in
                            if view.isFirstResponder{
                                view.resignFirstResponder()
                            }
                        })
                    })
                    
                    self.dismiss(animated: true, completion: nil)
                }
                else{
                    self.buildButton.isEnabled = true
                    self.displayNetworkError(error: error!, onReturnWithTextFields: { (data) in
                        self.delegate?.updateAccount(data: data)
                        self.triggerBuild()
                    })
                }
            }
        })
    }
    
    func updateButton(){
        buildButton.isEnabled = parameters.isEmpty || parameterValues.reduce(true){ $0 && $1.value != nil }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parameters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.parameterCell, for: indexPath) as! ParameterTableViewCell

        cell.parameter = parameters[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension ParametersTableViewController: ParameterTableViewCellDelegate{
    func set(value: String?, for parameter: Parameter) {
        parameterValues.first(where: { $0.parameter.hashValue == parameter.hashValue })?.value = value
        updateButton()
    }
}
