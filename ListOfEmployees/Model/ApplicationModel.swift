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
    private let persistentStorage: PersistentStorage?

    // MARK: - Initialization -

    init() {
        self.jsonParser = JsonParser.init(dispatchQueue: DispatchQueue.global(qos: .userInitiated))
        self.remoteDataFetcher = RemoteDataFetcher.init(dispatchQueue: DispatchQueue.global(qos: .userInitiated))
        self.persistentStorage = PersistentStorage.init(dispatchQueue: DispatchQueue.global(qos: .background))
    }

    // MARK: - Public methods -

    func setup()  {
        remoteDataFetcher.delegate = self
        jsonParser.delegate = self
    }

    func startFetchingDataFromRemoteServerIfPossible() {


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
    func parsingFinishedSuccessfully(employees: [EmployeeCodable], initialData data: Data) {
        os_log("Data parsed successfully", log: ApplicationModel.logger, type: .default)
        persistentStorage?.cache(data: data, withName: ApplicationModel.cacheFileName)
    }

    func parsingFinishedWithError(error: Error) {

    }
}
