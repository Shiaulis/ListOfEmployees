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
    Protocol describes application model interface
*/
protocol DataProvider {
    var sortedEmployees:[EmployeePosition: [Employee]] { get }
    func searchForEmployees(usingText: String) -> [Employee]
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

    static private let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: ApplicationModel.self)

    // MARK: Private properties

    // Services
    private let persistentCacheStorage: PersistentCacheStorage?
    private let dataMapper: DataMapper
    private var contactsStore: CNContactStore?
    fileprivate let employeesReadWriteQueue: DispatchQueue
    // Data
    private let dataSourceURLs: [URL]
    fileprivate var employeesSortedArray: [Employee]

    // MARK: - Initialization -

    init() {
        // The queue provides an ability to read/write data synchronously to avoid reader-writer problem
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
        grantAccessToContacts { [weak self] in
            self?.persistentCacheStorage?.startReadingCacheData()
        }
    }

    func fetchRemoteData(completionHandler: ((Error?) -> Void)?) {
        var remoteRequest:RemoteRequest? = RemoteRequest()
        remoteRequest?.performRequest(usingURLs: self.dataSourceURLs,
                                           queue: DispatchQueue.global(qos: .userInitiated),
                                           completionHandler: { (dataObjects, responses, errors) in
            // To capture remoteRequest inside the block
            // we use its variable inside the block.
            remoteRequest = nil
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
            self.dataMapper.parse(dataObjects: dataObjects, usingContacts: self.contactsStore) { [weak self] (error, employees) in
                guard let strongSelf = self else {
                    assertionFailure()
                    return
                }
                strongSelf.persistentCacheStorage?.cache(dataObjects: dataObjects)
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
            os_log("Start restoring data from cache", log: ApplicationModel.logger, type: .debug)
            persistentCacheStorage?.startReadingCacheData()
        }
        else {
            os_log("Data from cache cannot be retreived. Cache not available", log: ApplicationModel.logger, type: .error)
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

    private func grantAccessToContacts(completionHandler:@escaping ()->Void) {
        let contactsStore = CNContactStore()
        contactsStore.requestAccess(for: .contacts) { [weak self] (granted, error) in
            if let error = error {
                os_log("Failed to access contacts due to error '%@'", log: ApplicationModel.logger, type: .error, error.localizedDescription)
                completionHandler()
                return
            }

            if granted == false {
                os_log("Access to contacts denied by user", log: ApplicationModel.logger, type: .default)
                completionHandler()
                return
            }

            os_log("Access to contacts granted by user", log: ApplicationModel.logger, type: .debug)

            guard let strongSelf = self else {
                assertionFailure()
                return
            }
            // Contact store property is not nil if only acess to contacts is granted by the user
            strongSelf.contactsStore = contactsStore
            NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.contactsStoreDidChangeAction), name: Notification.Name.CNContactStoreDidChange, object: nil)
            // We should read data again to match employees with contacts list
            completionHandler()
        }
    }

    @objc private func contactsStoreDidChangeAction() {
        // We should read data again to match employees with contacts list if any changes will be made in contacts database
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

    func cachedDataIsReadedSuccessfully(dataObjects: [Data]) {
        os_log("Data read from cache successfully", log: ApplicationModel.logger, type: .default)
        self.dataMapper.parse(dataObjects: dataObjects, usingContacts: contactsStore) { [weak self] (error, employees) in
            guard let employeesArray = employees else {
                os_log("Failed to get employees from cached data", log: ApplicationModel.logger, type: .error)
                return
            }
            self?.employeesReadWriteQueue.sync { [weak self] in
                self?.employeesSortedArray = employeesArray.sorted()
            }
            NotificationCenter.default.post(name: .employeesListDidChangeExternally, object: nil)
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
    func searchForEmployees(usingText text: String) -> [Employee] {
        let targetLowercasedText = text.lowercased()
        return employeesSortedArray.filter { (employee) -> Bool in
            if employee.fullName.lowercased().contains(targetLowercasedText) {
                return true
            }
            if let email = employee.contactDetails?.email, email.lowercased().contains(targetLowercasedText) {
                return true
            }

            if  let position = employee.position, position.rawValue.lowercased().contains(targetLowercasedText) || position.description.lowercased().contains(targetLowercasedText) {
                return true
            }

            guard let projects = employee.projects else {
                return false
            }

            for project in projects {
                if project.lowercased().contains(targetLowercasedText) {
                    return true
                }
            }
            return false
        }
    }

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
