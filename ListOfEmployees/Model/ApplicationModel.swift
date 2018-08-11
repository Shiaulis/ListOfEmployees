//
//  ApplicationModel.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation

class ApplicationModel {

    // MARK: - Properties -

    // MARK: Resources

    static private let dataURLStringsArray =
    ["http://tallinn.jobapp.aw.ee/employee_list",
     "http://tartu.jobapp.aw.ee/employee_list"]

    static private let cacheFileName = "cachedData"
    

    // MARK: Private properties

    private let jsonParser: JsonParser
    private let remoteDataFetcher: RemoteDataFetcher
    private let persistentStorage: PersistentStorage?

    // MARK: - Initialization -

    init() {
        self.jsonParser = JsonParser.init(dispatchQueue: DispatchQueue.global(qos: .userInitiated))
        self.remoteDataFetcher = RemoteDataFetcher.init(with: URLSession.shared,
                                                        dispatchQueue: DispatchQueue.global(qos: .userInitiated))
        self.persistentStorage = PersistentStorage.init(dispatchQueue: DispatchQueue.global(qos: .background))
    }

    // MARK: - Public methods -

    func setup()  {
        remoteDataFetcher.delegate = self
        jsonParser.delegate = self
    }

    func startFetchingDataFromRemoteServerIfPossible() {
        for urlString in ApplicationModel.dataURLStringsArray {
            guard let url = URL.init(string: urlString) else {
                assertionFailure("Failed to construct url from string \(urlString)")
                // FIXME: Create some error, implement and call some error handler
                return
            }

            remoteDataFetcher.startFetchData(from: url)
        }
    }
}

extension ApplicationModel: RemoteDataFetcherDelegate {
    func remoteDataFetchRequestSuccess(data: Data, response: URLResponse) {
        jsonParser.parse(data: data)
    }

    func remoteDataFetchRequestFailed(error: Error) {

    }
}

extension ApplicationModel: JsonParserDelegate {
    func parsingFinishedSuccessfully(employees: [EmployeeCodable], initialData data: Data) {
        persistentStorage?.cache(data: data, withName: ApplicationModel.cacheFileName)
    }

    func parsingFinishedWithError(error: Error) {

    }
}
