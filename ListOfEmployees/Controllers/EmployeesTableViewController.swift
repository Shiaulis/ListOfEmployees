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

    private let dataProvider: DataProvider
    fileprivate var employees: [Character:[Employee]]
    var shouldUseCachedList: Bool

    // MARK: - Initialization -

    init(usingDataProvider dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        self.employees = [:]
        self.shouldUseCachedList = false
        super.init(nibName: nil, bundle: nil)
        NSLog("TEST: created view controller")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldUseCachedList = true
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return employees.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeesArray(forSection: section)?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        guard let employee = employee(forIndexPath: indexPath) else {
            assertionFailure()
            return cell
        }

        cell.textLabel?.text = employee.firstName
        cell.detailTextLabel?.text = employee.lastName
        return cell
    }

    // MARK: - Private methods -

    @objc private func didUpdateEmployeesAction() {
        employees = dataProvider.sortedEmployees
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func employeesArray(forSection section: Int) -> [Employee]? {
        let sortedKeysArray = employees.keys.sorted()
        if sortedKeysArray.count <= section {
            assertionFailure()
            return nil
        }
        let targetKey = sortedKeysArray[section]
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
