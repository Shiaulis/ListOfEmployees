//
//  EmployeesTableViewController.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit
import ContactsUI

protocol ContactViewControllerProvider: class {
    func openContactViewController(for: Employee)
}

class EmployeesTableViewController: UITableViewController {

    // MARK: - Properties -
    private static let viewControllerTitle = NSLocalizedString("Employees", comment: "view controller title")
    private static let cellId = "EmployeesTableViewControllerCellId"
    private static let headerId = "EmployeesTableViewControllerHeaderId"

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self
    }

    // Data
    private let dataProvider: DataProvider
    private weak var contactViewControllerProvider: ContactViewControllerProvider?
    fileprivate var employees: [EmployeePosition:[Employee]] {
        didSet {
            if employees.count > 0 {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.backgroundView = nil
                }
            }
        }
    }
    var filteredEmployees: [Employee]

    // UI
    private let searchController: UISearchController

    // MARK: - Initialization -

    init(usingDataProvider dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        self.employees = [:]
        self.searchController = UISearchController(searchResultsController: nil)
        self.filteredEmployees = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        contactViewControllerProvider = self
        updateDataFromDataProvider()
        requestDataFromDataProvider()

        setupNavigationBar()
        setupTableView()
        setupSearchController()
        view.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(employeesListDidChangeExternallyAction), name: .employeesListDidChangeExternally, object: nil)
        if employees.count == 0 {
            tableView.backgroundView = PlaceholderView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Because the CNContactViewController has different tint color
        // we should return it back to global value
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - Table view data source -

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        }
        return employees.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredEmployees.count
        }
        return employeesArray(forSection: section)?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmployeesTableViewController.cellId, for: indexPath)
        guard let employee = getEmployee(forIndexPath: indexPath) else {
            assertionFailure()
            return cell
        }

        guard let employeeCell = cell as? EmployeeTableViewCell else {
            assertionFailure()
            return cell
        }

        employeeCell.delegate = self
        employeeCell.employee = employee
        return employeeCell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let targetPosition = key(forSection: section) else {
            assertionFailure()
            return nil
        }

        guard let employeeTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: EmployeesTableViewController.headerId) as? EmployeesTableHeaderView else {
            assertionFailure()
            return nil
        }

        employeeTableHeaderView.headerTitle = targetPosition.description
        return employeeTableHeaderView
    }

    // MARK: - Tableview delegate -

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let employee = getEmployee(forIndexPath: indexPath) else {
            assertionFailure()
            return
        }
        let employeeDetailsViewController = EmployeeDetailsViewController(withEmployee: employee)
        employeeDetailsViewController.contactViewControllerProvider = self
        navigationController?.pushViewController(employeeDetailsViewController, animated: true)
    }

    // MARK: - Private methods -

    // MARK: Setup views

    private func setupNavigationBar() {
        navigationItem.title = EmployeesTableViewController.viewControllerTitle
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchButtonAction))
    }

    private func setupTableView() {
        tableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: EmployeesTableViewController.cellId)
        tableView.register(EmployeesTableHeaderView.self, forHeaderFooterViewReuseIdentifier: EmployeesTableViewController.headerId)
        tableView.rowHeight = UITableViewAutomaticDimension;
        // We extend our custom header view to screen bounds on devices with safe area
        tableView.insetsContentViewsToSafeArea = false
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Fetch data from remote server",
                                                                       attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)])
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search employee…", comment: "search placeholder")
        searchController.searchBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        searchController.searchBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        definesPresentationContext = true

    }

    @objc private func refreshControlAction() {
        requestDataFromDataProvider()
    }

    @objc private func employeesListDidChangeExternallyAction() {
        updateDataFromDataProvider()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    @objc private func searchButtonAction() {
        navigationItem.searchController = searchController
        navigationItem.searchController?.isActive = true
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.becomeFirstResponder()
        searchController.searchBar.delegate = self
    }

    private func requestDataFromDataProvider() {
        dataProvider.updateData { [weak self] (error) in
            if let error = error {
                print(error.localizedDescription)

            }
            self?.updateDataFromDataProvider()
            DispatchQueue.main.async { [weak self] in
                self?.tableView.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
        }
    }

    private func updateDataFromDataProvider() {
        employees = dataProvider.sortedEmployees
    }

    private func key(forSection section: Int) -> EmployeePosition? {
        let sortedKeysArray = employees.keys.sorted()
        if sortedKeysArray.count <= section {
            assertionFailure()
            return nil
        }
        return sortedKeysArray[section]
    }

    private func employeesArray(forSection section: Int) -> [Employee]? {

        if isFiltering() {
            return filteredEmployees
        }

        guard let targetKey = key(forSection: section) else {
            assertionFailure()
            return nil
        }
        guard let targetSectionArray = employees[targetKey] else {
            assertionFailure()
            return nil
        }
        return targetSectionArray
    }

    private func getEmployee(forIndexPath indexPath: IndexPath) -> Employee? {
        guard let employeesForSection = employeesArray(forSection: indexPath.section) else {
            assertionFailure()
            return nil
        }

        guard employeesForSection.count > indexPath.row else {
            assertionFailure()
            return nil
        }
        return employeesForSection[indexPath.row]
    }

    // Search related methods

    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        return searchController.isActive && searchBarIsEmpty() == false
    }

    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEmployees = dataProvider.searchForEmployees(usingText: searchText)
        tableView.reloadData()
    }
}

extension EmployeesTableViewController: EmployeeTableViewCellDelegate {
    func contactCardButtonTapped(sender: EmployeeTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else {
            assertionFailure()
            return
        }

        guard let employee = getEmployee(forIndexPath: tappedIndexPath) else {
                assertionFailure()
                return
        }

        contactViewControllerProvider?.openContactViewController(for: employee)
    }
}

extension EmployeesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            assertionFailure()
            return
        }
        filterContentForSearchText(searchText)
    }
}

extension EmployeesTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.searchController?.isActive = false
        navigationItem.searchController = nil
    }
}

extension EmployeesTableViewController: ContactViewControllerProvider {
    func openContactViewController(for employee: Employee) {
        guard let identifier = employee.contactsCardIdentifier else {
                assertionFailure()
                return
        }

        dataProvider.fetchContact(forIdentifier: identifier, keyDescriptor: CNContactViewController.descriptorForRequiredKeys()) { (contact) in
            guard let contact = contact else {
                assertionFailure()
                return
            }
            DispatchQueue.main.async {
                let viewController = CNContactViewController(for: contact)
                self.navigationController?.pushViewController(viewController, animated: true)
                viewController.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            }
        }
    }
}
