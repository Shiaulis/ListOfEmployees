//
//  EmployeesTableViewController.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit
import ContactsUI

class EmployeesTableViewController: UITableViewController {

    // MARK: - Properties -

    private static let cellId = "EmployeesTableViewControllerCellId"
    private static let headerId = "EmployeesTableViewControllerHeaderId"
    private static let viewControllerTitle = NSLocalizedString("Employees", comment: "view controller title")

    private let dataProvider: DataProvider
    fileprivate var employees: [EmployeePosition:[Employee]] {
        didSet {
            if employees.count > 0 {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.backgroundView = nil
                }
            }
        }
    }

    // MARK: - Initialization -

    init(usingDataProvider dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        self.employees = [:]
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadEmployeesFromCacheNotificationAction), name: .didLoadEmployeesFromCache, object: nil)
        updateDataFromDataProvider()
        tableView.refreshControl?.beginRefreshing()
        requestDataFromDataProvider()
        if employees.count == 0 {
            tableView.backgroundView = PlaceholderView()
        }
    }

    // MARK: - Table view data source -

    override func numberOfSections(in tableView: UITableView) -> Int {
        return employees.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        let employeeDetailsViewController = EmployeeDetailsViewController.init(for: employee)
        navigationController?.pushViewController(employeeDetailsViewController, animated: true)
    }

    // MARK: - Private methods -

    // MARK: Setup views

    private func setupNavigationBar() {
        navigationItem.title = EmployeesTableViewController.viewControllerTitle
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    }

    private func setupTableView() {
        tableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: EmployeesTableViewController.cellId)
        tableView.register(EmployeesTableHeaderView.self, forHeaderFooterViewReuseIdentifier: EmployeesTableViewController.headerId)
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Fetch data from remote server",
                                                                       attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)])
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        tableView.tableFooterView = UIView()
    }

    @objc private func refreshControlAction() {
        requestDataFromDataProvider()
    }

    @objc private func didLoadEmployeesFromCacheNotificationAction() {
        updateDataFromDataProvider()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
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
}

extension EmployeesTableViewController: EmployeeTableViewCellDelegate {
    func contactCardButtonTapped(sender: EmployeeTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else {
            assertionFailure()
            return
        }

        guard let employee = getEmployee(forIndexPath: tappedIndexPath),
            let identifier = employee.contactsCardIdentifier else {
                assertionFailure()
                return
        }
        dataProvider.fetchContact(forIdentifier: identifier, keyDescriptor: CNContactViewController.descriptorForRequiredKeys()) { (contact) in
            guard let contact = contact else {
                assertionFailure()
                return
            }
            DispatchQueue.main.async {
                let viewController = ContactCardViewController.init(for: contact)
                let navigationController = UINavigationController.init(rootViewController: viewController)

                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}
