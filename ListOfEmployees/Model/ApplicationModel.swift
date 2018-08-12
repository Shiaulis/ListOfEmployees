//
//  ApplicationModel.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import os.log
import Contacts

/**
    Protocol describes an interface from model to UI
*/
protocol DataProvider {
    var sortedEmployees:[Character: [Employee]] { get }
    func updateData()
}



class ApplicationModel {

    // MARK: - Properties -

    // MARK: Resources

    static private let dataURLStringsArray =
    ["http://tallinn.jobapp.aw.ee/employee_list",
     "http://tartu.jobapp.aw.ee/employee_list"]

    fileprivate static let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: ApplicationModel.self)

    // MARK: Private properties
    // Services
    fileprivate let userInitiatedConcurrentQueue: DispatchQueue
    fileprivate let employeesReadWriteQueue: DispatchQueue

    private let remoteDataFetcher: RemoteDataFetcher
    private let persistentCacheStorage: PersistentCacheStorage?
    private let dataMapper: DataMapper
    private let notificationCenter: NotificationCenter
    private var contactsStore: CNContactStore?
    // Data
    fileprivate var employeesSortedArray: [Employee] {
        didSet {
            notificationCenter.post(name: .didUpdateEmployees, object: self)
        }
    }

    // MARK: - Initialization -

    init() {
        self.userInitiatedConcurrentQueue = DispatchQueue(label: "com.shiaulis.ListOfEmployees.userInitiatedConcurrentQueue",
                                                          qos: .userInitiated,
                                                          attributes: .concurrent)

        self.employeesReadWriteQueue = DispatchQueue(label: "com.shiaulis.ListOfEmployees.employeesReadWriteQueue",
                                                     qos: .userInitiated,
                                                     attributes: .concurrent)

        self.remoteDataFetcher = RemoteDataFetcher(queue: self.userInitiatedConcurrentQueue)
        do {
            let cacheQueue = DispatchQueue(label: "cacheQueue",
                                           qos: .userInitiated)
            self.persistentCacheStorage = try PersistentCacheStorage(directoryName: "EmployeesDataCache", queue: cacheQueue)
        }
        catch {
            os_log("Failed to initiate cache. Error '%@'", log: ApplicationModel.logger, type: .error, error.localizedDescription)
            self.persistentCacheStorage = nil
        }
        self.dataMapper = DataMapper.init(queue: self.userInitiatedConcurrentQueue)
        self.notificationCenter = NotificationCenter.default

        self.employeesSortedArray = []
    }

    // MARK: - Public methods -

    func setup()  {
        remoteDataFetcher.delegate = self
        persistentCacheStorage?.delegate = self
        grantAccessToContacts()
    }

    func startFetchingRemoteData() {
        do {
            let urls: [URL] = try createURLsForRemoteDataFetching()
            remoteDataFetcher.startFetchData(from: urls)
        }
        catch {
            os_log("Failed to start fetching data. Error: '%@'",
                   log: ApplicationModel.logger,
                   type: .error,
                   error.localizedDescription)
        }
    }

    func restoreDataFromPersistentStorage() {
        persistentCacheStorage?.startReadingCacheData()
    }

    // MARK: - Private methods -

    private func createURLsForRemoteDataFetching() throws -> [URL] {
        let urls = try ApplicationModel.dataURLStringsArray.map { (urlString) -> URL in
            guard let url = URL.init(string: urlString) else {
                throw ApplicationModelError.stringToURLConvertError(urlString)
            }
            return url
        }
        return urls
    }

    /**
     This method expects sorted array as input parameter.
     Otherwise every value in this dictionary should be sorted afterwords.
     */
    private static func convertEmployeesSortedArrayToSortedDictionary(employeesSortedArray:[Employee]) -> [Character:[Employee]] {
        var dictionary:[Character:[Employee]] = [:]
        for employee in employeesSortedArray {
            guard let lastName = employee.lastName, let letter = lastName.first else {
                assertionFailure()
                continue
            }

            if dictionary[letter] != nil {
                dictionary[letter]?.append(employee)
            }
            else {
                dictionary[letter] = [employee]
            }
        }
        return dictionary
    }

    private func grantAccessToContacts() {
        let contactsStore = CNContactStore()
        contactsStore.requestAccess(for: .contacts) { [weak self] (granted, error) in
            if let error = error {
                os_log("Failed to access contacts due to error '%@'", log: ApplicationModel.logger, type: .error, error.localizedDescription)
                return
            }

            if granted == false {
                os_log("Access to contacts denied by user", log: ApplicationModel.logger, type: .default)
                return
            }

            os_log("Access to contacts granted by user", log: ApplicationModel.logger, type: .debug)

            // We save the property only if acess to contacts is granted by the user
            self?.contactsStore = contactsStore
        }
    }
}

extension ApplicationModel: RemoteDataFetcherDelegate {
    func remoteDataFetchRequestSuccess(datas: [Data], responses: [URLResponse]) {
        os_log("Remote data fetched succesfully", log: ApplicationModel.logger, type: .default)
        self.dataMapper.parse(datas: datas, usingContacts: self.contactsStore) { [weak self] (error, employees) in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }
            strongSelf.persistentCacheStorage?.cache(datas: datas)
            guard let employeesArray = employees else {
                assertionFailure()
                return
            }
            strongSelf.employeesSortedArray = employeesArray.sorted()
        }
    }

    func remoteDataFetchRequestFailed(errors: [Error]) {
        for error in errors {
            os_log("Failed to fetch remote data. Error '%@'",
                   log: ApplicationModel.logger,
                   type: .error,
                   error.localizedDescription)
        }
    }
}

extension ApplicationModel: PersistentCacheStorageDelegate {
    func cachingDataSucceeded() {
        os_log("Data cached successfully", log: ApplicationModel.logger, type: .default)
    }

    func cachingDataFailed(withError error: Error?) {
        os_log("Failed to cache data. Error '%@'",
               log: ApplicationModel.logger,
               type: .error,
               error?.localizedDescription ?? "")
    }

    func cachedDataIsReadedSuccessfully(datas: [Data]) {
        os_log("Data read from cache successfully", log: ApplicationModel.logger, type: .default)
        self.dataMapper.parse(datas: datas, usingContacts: contactsStore) { [weak self] (error, employees) in
            guard let employeesArray = employees else {
                os_log("Failed to get employees from cached data", log: ApplicationModel.logger, type: .error)
                return
            }
            self?.employeesReadWriteQueue.sync { [weak self] in
                self?.employeesSortedArray = employeesArray.sorted()
            }
        }
    }

    func cachedDataReadingFailed(withError error: Error?) {
        os_log("Failed to read data from cache. Error '%@'",
               log: ApplicationModel.logger,
               type: .error,
               error?.localizedDescription ?? "")
    }
}

extension ApplicationModel: DataProvider {
    var sortedEmployees: [Character : [Employee]] {
        return employeesReadWriteQueue.sync {
            return ApplicationModel.convertEmployeesSortedArrayToSortedDictionary(employeesSortedArray: self.employeesSortedArray)
        }
    }

    func updateData() {
        startFetchingRemoteData()
    }
}
