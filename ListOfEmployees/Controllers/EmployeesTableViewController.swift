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
    fileprivate var employees: [Employee]
    var shouldUseCachedList: Bool

    // MARK: - Initialization -

    init(usingDataProvider dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        self.employees = []
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
        dataProvider.setDataProviderDelegate(delegate: self)
        dataProvider.requestCachedList()
        shouldUseCachedList = true
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return employees.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "reuseIdentifier")

        cell.textLabel?.text = employees[indexPath.row].firstName
        cell.detailTextLabel?.text = employees[indexPath.row].lastName


        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EmployeesTableViewController: DataProviderDelegate {
    func cachedEmployeesList(error: Error?, cachedList: [Employee]?) {

        // FIXME: Check for error
        if shouldUseCachedList, let cachedEmployees = cachedList {
            employees = cachedEmployees
            NSLog("TEST: Received cached data")
            self.tableView.reloadData()
        }
    }

    func remoteEmployeesList(error: Error?, remoteList: [Employee]?) {
        // FIXME: Check for error
        if let remoteEmployees = remoteList {
            shouldUseCachedList = false
            employees = remoteEmployees
            NSLog("TEST: Received remote data")
            self.tableView.reloadData()
        }
    }
}
