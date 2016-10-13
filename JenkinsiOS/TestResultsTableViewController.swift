//
//  TestResultsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class TestResultsTableViewController: UITableViewController {

    var testResults: TestResult?{
        didSet{
            
            if let suites = testResults?.suites, suites.isEmpty == false{
                self.suites = suites
            }
            else if let suites = testResults?.childReports.flatMap({ (report) -> [Suite] in
                return report.result?.suites ?? []
            }){
                self.suites = suites
            }
            else{
                self.suites = []
            }
        }
    }
    var build: Build?
    var account: Account?
    
    var suites: [Suite] = []
    
    @IBOutlet weak var passedTestCountLabel: UILabel!
    @IBOutlet weak var skippedTestCountLabel: UILabel!
    @IBOutlet weak var failedTestCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTestResults()
        
        title = "Test Results"
    }
    
    private func loadTestResults(){
        guard let build = build, let account = account
            else { return }

        let userRequest = UserRequest(requestUrl: build.url.appendingPathComponent(Constants.API.testReport), account: account)
        
        NetworkManager.manager.getTestResult(userRequest: userRequest) { (testResult, error) in
            DispatchQueue.main.async {
                
                if let error = error{
                    self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                        self.account?.username = returnData["username"]!
                        self.account?.password = returnData["password"]!
                        
                        self.loadTestResults()
                    })
                }
                
                self.testResults = testResult
                self.tableView.reloadData()
                
                self.passedTestCountLabel.text = "Passed:\n" + (testResult?.passCount).textify()
                self.skippedTestCountLabel.text = "Skipped:\n" + (testResult?.skipCount).textify()
                self.failedTestCountLabel.text = "Failed:\n" + (testResult?.failCount).textify()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return suites.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suites[section].cases.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.testResultCell, for: indexPath) as! TestResultTableViewCell
        let testCase = suites[indexPath.section].cases[indexPath.row]
        cell.testNameLabel.text = testCase.name ?? "No name"
        cell.testDurationLabel.text = testCase.duration != nil ? "(\(testCase.duration!)ms)" : "Unknown"
        cell.testResultImageView.image = testCase.status != nil ? UIImage(named: "\(testCase.status!.lowercased())TestCase") : nil
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        
        if !UIAccessibilityIsReduceTransparencyEnabled(){
            
            let effect = UIBlurEffect(style: .light)
            let effectView = UIVisualEffectView(effect: effect)
            
            effectView.frame = view.bounds
            effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            view.addSubview(effectView)
        }
        
        label.attributedText = NSAttributedString(string: suites[section].name ?? "No name", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)])
        label.numberOfLines = 0
        label.sizeToFit()
        
        label.frame = view.bounds
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.clear
        
        view.addSubview(label)
        
        label.layoutMarginsGuide.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 20).isActive = true
        label.layoutMarginsGuide.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: 20).isActive = true
        label.layoutMarginsGuide.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        label.layoutMarginsGuide.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        label.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        return view
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showTestResultSegue, let dest = segue.destination as? TestResultTableViewController,
            let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell){
            dest.testCase = suites[indexPath.section].cases[indexPath.row]
        }
    }

}
