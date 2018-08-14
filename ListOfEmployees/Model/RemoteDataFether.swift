//
//  RemoteDataFether.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import os.log

class RemoteDataFetcher {

    // MARK: - Properties -

    private var dataObjects: [Data]
    private var responses: [URLResponse]
    private var errors: [Error]
    private static let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: RemoteDataFetcher.self)

    // MARK: - Initialization -

    init() {
        self.dataObjects = []
        self.responses = []
        self.errors = []
    }

    // MARK: - Public methods

    func fetchRemoteData(fromURLs urls:[URL], queue:DispatchQueue, completionHandler:@escaping ([Data], [URLResponse], [Error]) -> Void) {
        queue.async { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }
            let urlSession = URLSession.init(configuration: .default)
            let group = DispatchGroup.init()
            for url in urls {
                group.enter()
                os_log("Data fetch request started for URL '%@'", log: RemoteDataFetcher.logger, type: .debug, url.absoluteString)
                urlSession.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                    self?.handleNetworkResponse(data: data, response: response, error: error, dispatchGroup: group, queue: queue)
                }).resume()
            }

            strongSelf.waitForFinishAllFetches(withGroup: group, queue: queue, completionHandler: completionHandler)
        }

    }

    // MARK: - Private methods -

    private func handleNetworkResponse(data: Data?, response: URLResponse?, error: Error?, dispatchGroup: DispatchGroup, queue: DispatchQueue) {
        queue.sync { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                dispatchGroup.leave()
                return
            }

            if let error = error {
                os_log("Data fetch request for URL '%@' finished with error %@",
                       log: RemoteDataFetcher.logger,
                       type: .debug,
                       response?.url?.path ?? "", error.localizedDescription)
                strongSelf.errors.append(error)
                dispatchGroup.leave()
                return
            }

            guard let data = data else {
                assertionFailure("Data expected to exist")
                dispatchGroup.leave()
                return
            }


            guard let response = response else {
                assertionFailure("Response expected to exist")
                dispatchGroup.leave()
                return
            }

            os_log("Data fetch request for URL '%@' finished successfully",
                   log: RemoteDataFetcher.logger,
                   type: .debug,
                   response.url?.absoluteString ?? "")

            strongSelf.dataObjects.append(data)
            strongSelf.responses.append(response)
            dispatchGroup.leave()

        }
    }

    private func waitForFinishAllFetches(withGroup group: DispatchGroup, queue: DispatchQueue, completionHandler:@escaping ([Data], [URLResponse], [Error]) -> Void) {
        group.notify(queue: queue) { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }

            completionHandler(strongSelf.dataObjects, strongSelf.responses, strongSelf.errors)
        }
    }
}


