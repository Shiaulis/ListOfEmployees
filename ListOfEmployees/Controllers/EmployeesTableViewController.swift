//
//  EmployeesTableViewController.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class EmployeesTableViewController: UITableViewController {

    // MARK: - Properties -

    private static let cellId = "EmployeesTableViewControllerCellId"
    private static let viewControllerTitle = NSLocalizedString("Employees", comment: "view controller title")

    private let dataProvider: DataProvider
    fileprivate var employees: [Character:[Employee]]

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
        self.tableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: EmployeesTableViewController.cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        employees = dataProvider.sortedEmployees
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateEmployeesAction), name: .didUpdateEmployees, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: .didUpdateEmployees, object: nil)
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
        guard let employee = employee(forIndexPath: indexPath) else {
            assertionFailure()
            return cell
        }

//        cell.textLabel?.text = employee.firstName
//        cell.detailTextLabel?.text = employee.lastName
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let targetKey = key(forSection: section) else {
            assertionFailure()
            return nil
        }

        let label = UILabel.init()
        label.text = String.init(targetKey)
        label.backgroundColor = .lightGray
        return label
    }

    // MARK: - Private methods -

    // MARK: Setup views

    private func setupNavigationBar() {
        navigationItem.title = EmployeesTableViewController.viewControllerTitle
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 200.0;
    }

    @objc private func didUpdateEmployeesAction() {
        employees = dataProvider.sortedEmployees
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func key(forSection section: Int) -> Character? {
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

    private func employee(forIndexPath indexPath: IndexPath) -> Employee? {
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
