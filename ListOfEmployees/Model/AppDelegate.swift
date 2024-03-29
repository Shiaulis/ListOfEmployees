//
//  AppDelegate.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties -

    private let window: UIWindow
    private let applicationModel: ApplicationModel

    // MARK: - Initialization -

    override init() {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.applicationModel = ApplicationModel.init()
        super.init()
    }

    // MARK: - UIApplicationDelegate methods

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        applicationModel.setup()
        applicationModel.startRestoringDataFromPersistentStorageIfPossible()
        
        return true;
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let employeesTableViewController = EmployeesTableViewController.init(usingDataProvider: applicationModel)
        let navigationController = UINavigationController.init(rootViewController: employeesTableViewController)
        navigationController.navigationBar.tintColor = .white
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return true
    }
}
