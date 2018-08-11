//
//  ApplicationModel.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import os.log

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


    static private let cacheFileName = "cachedData"
    fileprivate static let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: ApplicationModel.self)

    // MARK: Private properties

    private let jsonParser: JsonParser
    private let remoteDataFetcher: RemoteDataFetcher
    private let persistentCacheStorage: PersistentCacheStorage?
    private let notificationCenter: NotificationCenter
    fileprivate var employeesSortedArray: [Employee] {
        didSet {
            notificationCenter.post(name: .didUpdateEmployees, object: self)
        }
    }
    fileprivate let employeesReadWriteQueue: DispatchQueue


    // MARK: - Initialization -

    init() {
        self.jsonParser = JsonParser.init(dispatchQueue: DispatchQueue.global(qos: .userInitiated))
        self.remoteDataFetcher = RemoteDataFetcher.init(dispatchQueue: DispatchQueue.global(qos: .userInitiated))
        do {
            self.persistentCacheStorage = try PersistentCacheStorage.init(directoryName: "UsersDataCache", dispatchQueue: DispatchQueue.global(qos: .background))
        }
        catch {
            os_log("Failed to initiate cache. Error '%@'", log: ApplicationModel.logger, type: .error, error.localizedDescription)
            self.persistentCacheStorage = nil
        }
        self.notificationCenter = NotificationCenter.default
        self.employeesReadWriteQueue = DispatchQueue.global(qos: .userInteractive)
        self.employeesSortedArray = []
    }

    // MARK: - Public methods -

    func setup()  {
        remoteDataFetcher.delegate = self
        persistentCacheStorage?.delegate = self
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
}

extension ApplicationModel: RemoteDataFetcherDelegate {
    func remoteDataFetchRequestSuccess(datas: [Data], responses: [URLResponse]) {
        os_log("Remote data fetched succesfully", log: ApplicationModel.logger, type: .default)
        jsonParser.parse(datas: datas) { [weak self] (error, employees) in
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
        jsonParser.parse(datas: datas) { [weak self] (error, employees) in
            guard let employeesArray = employees else {
                os_log("Failed to get employees from cached data", log: ApplicationModel.logger, type: .error)
                return
            }
            self?.employeesReadWriteQueue.async(flags: .barrier) { [weak self] in
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
