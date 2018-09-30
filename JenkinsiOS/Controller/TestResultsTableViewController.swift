//
//  TestResultsTableViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit

class TestResultsTableViewController: RefreshingTableViewController {
    var testResults: TestResult? {
        didSet {
            updateCases()
        }
    }

    var build: Build?
    var account: Account?

    private var cases: [Case] = []

    private var currentScope: TestResultScope = .all {
        didSet {
            updateCases()
        }
    }

    @IBOutlet var searchBarContainer: UIView!
    @IBOutlet var passedCountLabel: UILabel!
    @IBOutlet var skippedCountLabel: UILabel!
    @IBOutlet var failedCountLabel: UILabel!
    @IBOutlet var filterSegment: UISegmentedControl!

    private var searchController: UISearchController?
    private let cellNib = UINib(nibName: "TestResultTableViewCell", bundle: .main)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Results"

        tableView.register(cellNib, forCellReuseIdentifier: Constants.Identifiers.testResultCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = Constants.UI.backgroundColor

        let searchImage = UIImage(named: "search")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchImage, landscapeImagePhone: searchImage, style: .plain, target: self, action: #selector(search))

        filterSegment.addTarget(self, action: #selector(filter), for: .valueChanged)

        emptyTableView(for: .loading)
        loadTestResults()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController?.searchBar.text = ""
    }

    override func refresh() {
        loadTestResults()
        emptyTableView(for: .loading)
    }

    private func clearUI() {
        tableView.tableHeaderView?.isHidden = true
    }

    private func fillUI() {
        tableView.tableHeaderView?.isHidden = (testResults == nil)

        tableView.reloadData()
        setUpSearchController()

        refreshControl?.endRefreshing()

        guard let result = testResults
        else { return }

        passedCountLabel.text = result.passCount.textify()
        skippedCountLabel.text = result.skipCount.textify()
        failedCountLabel.text = result.failCount.textify()

        tableView.contentOffset.y = searchBarContainer.frame.height - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.height
    }

    private func updateCases() {
        var suites: [Suite] = []

        if let providedSuites = testResults?.suites, providedSuites.isEmpty == false {
            suites = providedSuites
        } else if let providedSuites = testResults?.childReports.flatMap({ (report) -> [Suite] in
            report.result?.suites ?? []
        }) {
            suites = providedSuites
        }

        cases = suites.flatMap({ $0.cases }).filter { $0.status == nil || currentScope.equals(status: $0.status!) }
    }

    // MARK: - Data loading

    private func loadTestResults() {
        guard let build = build, let account = account
        else { return }

        clearUI()

        let userRequest = UserRequest(requestUrl: build.url.appendingPathComponent(Constants.API.testReport), account: account)

        _ = NetworkManager.manager.getTestResult(userRequest: userRequest) { testResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    if let networkManagerError = error as? NetworkManagerError, networkManagerError.code == 404 {
                        self.emptyTableView(for: .noData, action: self.defaultRefreshingAction)
                    } else {
                        self.displayNetworkError(error: error, onReturnWithTextFields: { returnData in
                            self.account?.username = returnData["username"]!
                            self.account?.password = returnData["password"]!

                            self.loadTestResults()
                        })
                        self.emptyTableView(for: .error, action: self.defaultRefreshingAction)
                    }

                    return
                }

                self.testResults = testResult
                self.fillUI()
                self.emptyTableView(for: .noData, action: self.defaultRefreshingAction)
            }
        }
    }

    @objc private func search() {
        searchController?.searchBar.becomeFirstResponder()
    }

    @objc private func filter() {
        guard let title = filterSegment.titleForSegment(at: filterSegment.selectedSegmentIndex), let scope = TestResultScope(rawValue: title)
        else { return }

        currentScope = scope
        tableView.reloadData()
    }

    private func setUpSearchController() {
        guard cases.count > 0
        else { return }

        let searchData = getSearchData()

        let searchResultsController = SearchResultsTableViewController(searchData: searchData, cellNib: cellNib)

        setupSearchResultsController(controller: searchResultsController)

        searchController = UISearchController(searchResultsController: searchResultsController)
        searchBarContainer.addSubview(searchController!.searchBar)

        setupSearchController(controller: searchController, with: searchResultsController)
    }

    private func setupSearchController(controller: UISearchController?, with searchResultsController: SearchResultsTableViewController) {
        controller?.searchBar.isUserInteractionEnabled = true

        controller?.searchBar.scopeButtonTitles = TestResultScope.getScopeStrings()
        controller?.searchResultsUpdater = searchResultsController.searcher
        controller?.searchBar.delegate = searchResultsController.searcher
    }

    private func setupSearchResultsController(controller: SearchResultsTableViewController) {
        controller.delegate = self
        controller.searcher?.includeAllOnEmptySearchString = true
        controller.searcher?.additionalSearchCondition = getAdditionalSearchCondition()
    }

    private func getAdditionalSearchCondition() -> ((Searchable, String?) -> Bool) {
        return {
            (searchable, scopeString) -> Bool in
            guard let scopeString = scopeString, let scope = TestResultScope(rawValue: scopeString), let testCase = searchable.data as? Case
            else { return false }
            guard let status = testCase.status
            else { return scope == .failed }
            return scope.equals(status: status)
        }
    }

    private func getSearchData() -> [Searchable] {
        return cases.map(searchable(for:))
    }

    private func searchable(for testCase: Case) -> Searchable {
        return Searchable(searchString: testCase.name ?? testCase.className ?? "Unknown", data: testCase) {
            self.searchController?.dismiss(animated: true) {
                self.performSegue(withIdentifier: Constants.Identifiers.showTestResultSegue, sender: testCase)
            }
        }
    }

    private enum TestResultScope: String {
        case all = "All"
        case passed = "Passed"
        case skipped = "Skipped"
        case failed = "Failed"

        static func getScopeStrings() -> [String] {
            return [TestResultScope.all, .passed, .skipped, .failed].map { $0.rawValue }
        }

        func equals(status: Case.Status) -> Bool {
            guard self != .all
            else { return true }

            return Case.Status(rawValue: rawValue.uppercased()) == status
        }
    }

    // MARK: - Table view data source

    override func numberOfSections() -> Int {
        return 1
    }

    override func tableViewIsEmpty() -> Bool {
        return cases.count == 0
    }

    override func separatorStyleForNonEmpty() -> UITableViewCell.SeparatorStyle {
        return .none
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return cases.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 78
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.testResultCell, for: indexPath) as! TestResultTableViewCell
        cell.test = cases[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.showTestResultSegue, sender: cases[indexPath.row])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.showTestResultSegue, let dest = segue.destination as? TestResultTableViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                dest.testCase = cases[indexPath.row]
            } else if let testCase = sender as? Case {
                dest.testCase = testCase
            }
        }
    }
}

extension TestResultsTableViewController: SearchResultsControllerDelegate {
    func setup(cell: UITableViewCell, for searchable: Searchable) {
        guard let cell = cell as? TestResultTableViewCell
        else { return }
        cell.test = searchable.data as? Case
    }
}
