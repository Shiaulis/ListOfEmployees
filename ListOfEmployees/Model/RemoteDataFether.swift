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

    private let dispatchQueue: DispatchQueue
    private let dataSourceURLs: [URL]
    private var datas: [Data]
    private var responses: [URLResponse]
    private var errors: [Error]
    private static let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: RemoteDataFetcher.self)

    // MARK: - Initialization -

    init(queue: DispatchQueue, dataSourceURLStrings: [String]) {
        self.dispatchQueue = queue
        var dataSourceURLs: [URL] = []
        for urlString in dataSourceURLStrings {
            if let url = URL(string: urlString) {
                dataSourceURLs.append(url)
            }
            else {
                assertionFailure()
            }
        }
        self.dataSourceURLs = dataSourceURLs
        datas = []
        responses = []
        errors = []
    }

    // MARK: - Public methods

    func startFetchData(completionHandler:@escaping ([Data], [URLResponse], [Error]) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }
            let urlSession = URLSession.init(configuration: .default)
            let group = DispatchGroup.init()
            for url in strongSelf.dataSourceURLs {
                group.enter()
                os_log("Data fetch request started for URL '%@'", log: RemoteDataFetcher.logger, type: .debug, url.absoluteString)
                urlSession.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                    self?.handleNetworkResponse(data: data, response: response, error: error, dispatchGroup: group)
                }).resume()
            }

            strongSelf.waitForFinishAllFetches(withGroup: group, completionHandler: completionHandler)
        }

    }

    func handleNetworkResponse(data: Data?, response: URLResponse?, error: Error?, dispatchGroup: DispatchGroup) {
        dispatchQueue.sync { [weak self] in
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

            strongSelf.datas.append(data)
            strongSelf.responses.append(response)
            dispatchGroup.leave()

        }
    }

    func waitForFinishAllFetches(withGroup group: DispatchGroup, completionHandler:@escaping ([Data], [URLResponse], [Error]) -> Void) {
        group.notify(queue: dispatchQueue) { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }

            completionHandler(strongSelf.datas, strongSelf.responses, strongSelf.errors)
        }
    }
}


