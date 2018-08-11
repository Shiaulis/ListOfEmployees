//
//  ApplicationModel.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import os.log

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
    }

    // MARK: - Public methods -

    func setup()  {
        remoteDataFetcher.delegate = self
        jsonParser.delegate = self
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

    private func createURLsForRemoteDataFetching() throws -> [URL] {
        let urls = try ApplicationModel.dataURLStringsArray.map { (urlString) -> URL in
            guard let url = URL.init(string: urlString) else {
                throw ApplicationModelError.stringToURLConvertError(urlString)
            }
            return url
        }
        return urls
    }
}

extension ApplicationModel: RemoteDataFetcherDelegate {
    func remoteDataFetchRequestSuccess(datas: [Data], responses: [URLResponse]) {
        os_log("Remote data fetched succesfully", log: ApplicationModel.logger, type: .default)
        jsonParser.parse(datas: datas)
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

extension ApplicationModel: JsonParserDelegate {
    func parsingFinishedSuccessfully(employees: [EmployeeCodable], initialDatas datas: [Data]) {
        os_log("Data parsed successfully", log: ApplicationModel.logger, type: .default)
        persistentCacheStorage?.cache(datas: datas)
    }

    func parsingFinishedWithError(error: Error) {
        os_log("Failed to parse data. Error '%@'",
               log: ApplicationModel.logger,
               type: .error,
               error.localizedDescription)
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
    }

    func cachedDataReadingFailed(withError error: Error?) {
        os_log("Failed to read data from cache. Error '%@'",
               log: ApplicationModel.logger,
               type: .error,
               error?.localizedDescription ?? "")
    }
}
