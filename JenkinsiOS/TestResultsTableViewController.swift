//
//  TestResultsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class TestResultsTableViewController: RefreshingTableViewController {

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
    @IBOutlet weak var searchBarContainer: UIView!
    
    private var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Results"
        emptyTableView(for: .loading)
        loadTestResults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController?.searchBar.text = ""
    }

    override func refresh(){
        loadTestResults()
    }

    private func clearUI(){
        tableView.tableHeaderView?.isHidden = true
    }
    
    private func fillUI(){
        
        tableView.tableHeaderView?.isHidden = false
        
        tableView.reloadData()
        setUpSearchController()
        
        passedTestCountLabel.text = "Passed:\n\((testResults?.passCount).textify())"
        skippedTestCountLabel?.text = "Skipped:\n\((testResults?.skipCount).textify())"
        failedTestCountLabel?.text = "Failed:\n\((testResults?.failCount).textify())"
        refreshControl?.endRefreshing()
    }
    
    //MARK: - Data loading
    @objc private func loadTestResults(){
        guard let build = build, let account = account
            else { return }
        
        clearUI()
        
        let userRequest = UserRequest(requestUrl: build.url.appendingPathComponent(Constants.API.testReport), account: account)
        
        NetworkManager.manager.getTestResult(userRequest: userRequest) { (testResult, error) in
            DispatchQueue.main.async {
                
                if let error = error{
                    if let networkManagerError = error as? NetworkManagerError, networkManagerError.code == 404{
                        self.emptyTableView(for: .noData)
                    }
                    else{
                        self.displayNetworkError(error: error, onReturnWithTextFields: { (returnData) in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!
                            
                            self.loadTestResults()
                        })
                        self.emptyTableView(for: .error)
                    }
                }
                
                self.testResults = testResult
                self.fillUI()
                self.emptyTableView(for: .noData)
            }
        }
    }
    
    private func setUpSearchController(){
        
        guard suites.count > 0
            else { return }
        
        let searchData = getSearchData()

        let searchResultsController = SearchResultsTableViewController(searchData: searchData)
        
        setupSearchResultsController(controller: searchResultsController)
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchBarContainer.addSubview(searchController!.searchBar)
        
        setupSearchController(controller: searchController, with: searchResultsController)
    }
    
    private func setupSearchController(controller: UISearchController?, with searchResultsController: SearchResultsTableViewController){
        controller?.searchBar.isUserInteractionEnabled = true
        
        controller?.searchBar.scopeButtonTitles = TestResultScope.getScopeStrings()
        controller?.searchResultsUpdater = searchResultsController.searcher
        controller?.searchBar.delegate = searchResultsController.searcher
    }
    
    private func setupSearchResultsController(controller: SearchResultsTableViewController){
        controller.delegate = self
        controller.cellStyle = .subtitle
        controller.searcher?.includeAllOnEmptySearchString = true
        controller.searcher?.additionalSearchCondition = getAdditionalSearchCondition()
    }
    
    private func getAdditionalSearchCondition() -> ((Searchable, String?) -> Bool){
        return {
            (searchable, scopeString) -> Bool in
            guard let scopeString = scopeString, let scope = TestResultScope(rawValue: scopeString), let testCase = searchable.data as? Case, let status = testCase.status
                else { return true }
            return scope.equals(status: status)
        }
    }
    
    private func getSearchData() -> [Searchable]{
        var searchData: [Searchable] = []
        
        for suite in suites{
            for testCase in suite.cases{
                searchData.append(searchable(for: testCase))
            }
        }
        
        return searchData
    }
    
    private func searchable(for testCase: Case) -> Searchable {
        return Searchable(searchString: testCase.name ?? testCase.className ?? "Unknown", data: testCase){
            self.searchController?.dismiss(animated: true){
                self.performSegue(withIdentifier: Constants.Identifiers.showTestResultSegue, sender: testCase)
            }
        }
    }
    
    private enum TestResultScope: String{
        case all = "All"
        case passed = "Passed"
        case skipped = "Skipped"
        case failed = "Failed"
        
        static func getScopeStrings() -> [String]{
            return [TestResultScope.all, .passed, .skipped, .failed].map{ $0.rawValue }
        }
        
        func equals(status: Case.Status) -> Bool{
            guard self != .all
                else { return true }
            
            return Case.Status(rawValue: self.rawValue.uppercased()) == status
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections() -> Int {
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
        
        if let status = testCase.status?.rawValue.lowercased(){
            cell.testResultImageView.image = UIImage(named: "\(status)TestCase")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        
        if !UIAccessibilityIsReduceTransparencyEnabled(){
            addVisualEffectView(to: view)
        }
        
        setUpHeaderLabel(label: label, for: suites[section])
        
        label.frame = view.bounds
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.clear
        
        view.addSubview(label)
        addConstraints(to: label, in: view)
        
        return view
    }
    
    private func addVisualEffectView(to headerView: UIView){
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        
        effectView.frame = headerView.bounds
        effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        headerView.addSubview(effectView)
    }
    
    private func addConstraints(to label: UILabel, in view: UIView){
        label.layoutMarginsGuide.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 20).isActive = true
        label.layoutMarginsGuide.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: 20).isActive = true
        label.layoutMarginsGuide.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        label.layoutMarginsGuide.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        label.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    private func setUpHeaderLabel(label: UILabel, for suite: Suite){
        label.attributedText = NSAttributedString(string: suite.name ?? "No name", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)])
        label.numberOfLines = 0
        label.sizeToFit()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showTestResultSegue, let dest = segue.destination as? TestResultTableViewController{
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell){
                dest.testCase = suites[indexPath.section].cases[indexPath.row]
            }
            else if let testCase = sender as? Case{
                dest.testCase = testCase
            }
            
        }
    }
}

extension TestResultsTableViewController: SearchResultsControllerDelegate{
    func setup(cell: UITableViewCell, for searchable: Searchable) {
        guard let testCase = searchable.data as? Case
            else { return }
        
        cell.detailTextLabel?.text = testCase.duration != nil ? "\(testCase.duration!)ms" : nil
        cell.textLabel?.text = testCase.name.textify()
        
        if let status = testCase.status?.rawValue.lowercased(), let image = UIImage(named: "\(status)TestCase"){
            cell.imageView?.withResized(image: image, size: CGSize(width: 20, height: 20))
            cell.imageView?.contentMode = .scaleAspectFit
        }
    }
}
