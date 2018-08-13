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
        NSLog("TEST: App started")
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.applicationModel = ApplicationModel.init()
        super.init()
    }

    // MARK: - UIApplicationDelegate methods

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        applicationModel.setup()
        applicationModel.fetchRemoteData(completionHandler: nil)
        applicationModel.restoreDataFromPersistentStorage()
        
        return true;
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        let employeesTableViewController = EmployeesTableViewController.init(usingDataProvider: applicationModel)
        let navigationController = UINavigationController.init(rootViewController: employeesTableViewController)
        window.rootViewController = navigationController
        window.tintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        window.makeKeyAndVisible()
        
        return true
    }
}

