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
    var sortedEmployees:[EmployeePosition: [Employee]] { get }
    func updateData(completionHandler: @escaping (Error?)->Void)
    func fetchContact(forIdentifier: String,
                      keyDescriptor: CNKeyDescriptor,
                      completionHandler:@escaping (CNContact?)->Void)
}

class ApplicationModel {

    // MARK: - Properties -

    // MARK: Resources

    static private let dataURLStringsArray =
    ["http://tallinn.jobapp.aw.ee/employee_list",
     "http://tartu.jobapp.aw.ee/employee_list"]

    fileprivate static let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: ApplicationModel.self)

    // MARK: Private properties
    fileprivate let employeesReadWriteQueue: DispatchQueue
    // Services
    private let persistentCacheStorage: PersistentCacheStorage?
    private let dataMapper: DataMapper
    private var contactsStore: CNContactStore?
    // Data
    private let dataSourceURLs: [URL]
    fileprivate var employeesSortedArray: [Employee]

    // MARK: - Initialization -

    init() {
        // This queue provides ability to read/write data synchronously without readler-writer problem
        self.employeesReadWriteQueue = DispatchQueue(label: "com.shiaulis.ListOfEmployees.employeesReadWriteQueue",
                                                     qos: .userInitiated)

        self.dataSourceURLs = ApplicationModel.createURLs(from: ApplicationModel.dataURLStringsArray)
        do {
            let cacheQueue = DispatchQueue(label: "cacheQueue",
                                           qos: .userInitiated)
            self.persistentCacheStorage = try PersistentCacheStorage(directoryName: "EmployeesDataCache", queue: cacheQueue)
        }
        catch {
            os_log("Failed to initiate cache. Error '%@'", log: ApplicationModel.logger, type: .error, error.localizedDescription)
            self.persistentCacheStorage = nil
        }
        self.dataMapper = DataMapper.init(queue: DispatchQueue.global(qos: .userInitiated))

        self.employeesSortedArray = []
    }

    // MARK: - Public methods -

    func setup()  {
        persistentCacheStorage?.delegate = self
        grantAccessToContacts()
    }

    func fetchRemoteData(completionHandler: ((Error?) -> Void)?) {
        var remoteDataFetcher:RemoteDataFetcher? = RemoteDataFetcher()
        remoteDataFetcher?.fetchRemoteData(fromURLs: self.dataSourceURLs,
                                           queue: DispatchQueue.global(qos: .userInitiated),
                                           completionHandler: { (dataObjects, responses, errors) in
            remoteDataFetcher = nil
            if errors.count > 0 {
                for error in errors {
                    os_log("Failed to fetch remote data. Error '%@'",
                           log: ApplicationModel.logger,
                           type: .error,
                           error.localizedDescription)
                }
                completionHandler?(ApplicationModelError.dataFetchError)
                return
            }

            if dataObjects.count == 0 {
                os_log("Unexpected zero data objects for response without errors",
                       log: ApplicationModel.logger,
                       type: .error)
                completionHandler?(ApplicationModelError.dataFetchError)
                return
            }

            os_log("Remote data fetched succesfully", log: ApplicationModel.logger, type: .default)
            self.dataMapper.parse(datas: dataObjects, usingContacts: self.contactsStore) { [weak self] (error, employees) in
                guard let strongSelf = self else {
                    assertionFailure()
                    return
                }
                strongSelf.persistentCacheStorage?.cache(datas: dataObjects)
                guard let employeesArray = employees else {
                    assertionFailure()
                    return
                }
                strongSelf.employeesReadWriteQueue.sync {
                    strongSelf.employeesSortedArray = employeesArray.sorted()
                }
                completionHandler?(nil)
            }
        })
    }


    func startRestoringDataFromPersistentStorageIfPossible() {
        if let persistentStorage = persistentCacheStorage, persistentStorage.isDataCached {
            persistentCacheStorage?.startReadingCacheData()
        }
    }

    // MARK: - Private methods -

    /**
     This method expects sorted array as input parameter.
     Otherwise every value in this dictionary should be sorted afterwords.
     */
    private static func convertEmployeesSortedArrayToSortedDictionary(employeesSortedArray:[Employee]) -> [EmployeePosition:[Employee]] {

        var dictionary:[EmployeePosition:[Employee]] = [:]

        for employee in employeesSortedArray {
            guard let position = employee.position else {
                assertionFailure()
                continue
            }

            if dictionary[position] != nil {
                dictionary[position]?.append(employee)
            }
            else {
                dictionary[position] = [employee]
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

            guard let strongSelf = self else {
                assertionFailure()
                return
            }
            // We save the property only if acess to contacts is granted by the user
            strongSelf.contactsStore = contactsStore
            NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.contactsStoreDidChange), name: Notification.Name.CNContactStoreDidChange, object: nil)
        }
    }

    @objc private func contactsStoreDidChange() {
        persistentCacheStorage?.startReadingCacheData()
    }

    private static func createURLs(from urlStrings:[String]) -> [URL] {
        var urls: [URL] = []
        for urlString in urlStrings {
            if let url = URL(string: urlString) {
                urls.append(url)
            }
            else {
                os_log("Failed to transform urlString '%@' to URL", log: ApplicationModel.logger, type: .error, urlString)
                assertionFailure()
            }
        }
        return urls
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
            NotificationCenter.default.post(name: .didLoadEmployeesFromCache, object: nil)
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
    func fetchContact(forIdentifier identifier: String, keyDescriptor: CNKeyDescriptor, completionHandler: @escaping (CNContact?) -> Void) {
        if let contactsStore = contactsStore {
            dataMapper.contact(forIdentifier: identifier, contactsStore: contactsStore, keyDescriptor: keyDescriptor, completionHandler: completionHandler)

        }
        else {
            os_log("Failed to get contact for identifier due to absense of contacts store", log: ApplicationModel.logger, type: .error)
            completionHandler(nil)
        }
    }

    
    var sortedEmployees: [EmployeePosition : [Employee]] {
        return employeesReadWriteQueue.sync {
            return ApplicationModel.convertEmployeesSortedArrayToSortedDictionary(employeesSortedArray: self.employeesSortedArray)
        }
    }

    func updateData(completionHandler: @escaping (Error?) -> Void) {
        fetchRemoteData(completionHandler: completionHandler)
    }
}
