//
//  EmployeeDetailsViewController.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 15.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class EmployeeDetailsViewController: UITableViewController {

    // MARK: - Properties -
    // Resources
    private static let contactDetailsHeaderTitle = NSLocalizedString("Contact Details", comment: "Header title in details view")
    private static let projectsHeaderTitle = NSLocalizedString("Projects", comment: "Header title in details view")

    private let employee: Employee

    // NARK: - Initialization -

    init(for employee: Employee) {
        self.employee = employee
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - TableViewDataSource methods -

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 1
        if employee.contactDetails?.email != nil || employee.contactDetails?.phone != nil {
            numberOfSections += 1
        }
        if let projects = employee.projects, projects.count > 0 {
            numberOfSections += 1
        }

        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            var numberOfRows = 0
            if employee.contactDetails?.email != nil {
                numberOfRows += 1
            }
            if employee.contactDetails?.phone != nil {
                numberOfRows += 1
            }
            return numberOfRows
        case 2:
            return employee.projects?.count ?? 0
        default:
            assertionFailure()
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return EmployeeDetailsViewCell.init(image: #imageLiteral(resourceName: "LaunchScreenImage"), title: employee.fullName, caption: employee.position?.description ?? "")
        }

        if indexPath.section == 1 {
            if indexPath.row == 0, let email = employee.contactDetails?.email {
                return EmployeeDetailsViewCell.init(image: #imageLiteral(resourceName: "EmailIcon"), title: "email", caption: email)
            }
            if indexPath.row == 1, let phone = employee.contactDetails?.phone {
                return EmployeeDetailsViewCell.init(image: #imageLiteral(resourceName: "PhoneIcon"), title: "phone", caption: phone)
            }
            assertionFailure()
            return UITableViewCell()
        }

        if indexPath.section == 2 {
            guard let projects = employee.projects else {
                assertionFailure()
                return UITableViewCell()
            }
            if projects.count <= indexPath.row {
                assertionFailure()
                return UITableViewCell()
            }

            return EmployeeDetailsViewCell.init(image: #imageLiteral(resourceName: "AddressBookButtonIcon"), title: projects[indexPath.row])
        }

        assertionFailure()
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        return 50
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            return EmployeesTableHeaderView(withTitle: EmployeeDetailsViewController.contactDetailsHeaderTitle)
        case 2:
            return EmployeesTableHeaderView(withTitle: EmployeeDetailsViewController.projectsHeaderTitle)
        default:
            assertionFailure()
            return nil
        }
    }


    // MARK: - Private methods -

    private func setupTableView() {
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    }
}
