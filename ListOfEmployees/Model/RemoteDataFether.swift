//
//  RemoteDataFether.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import os.log

protocol RemoteDataFetcherDelegate: class {
    func remoteDataFetchRequestSuccess(datas: [Data], responses: [URLResponse])
    func remoteDataFetchRequestFailed(errors: [Error])
}

class RemoteDataFetcher: NSObject {

    // MARK: - Properties -

    weak var delegate: RemoteDataFetcherDelegate?
    private let dispatchQueue: DispatchQueue
    private var datas: [Data]
    private var responses: [URLResponse]
    private var errors: [Error]
    private static let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: RemoteDataFetcher.self)

    // MARK: - Initialization -

    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
        datas = []
        responses = []
        errors = []
        super.init()
    }

    // MARK: - Public methods

    func startFetchData(from urls:[URL]) {
        dispatchQueue.async { [weak self] in
            let urlSession = URLSession.init(configuration: .default)
            let group = DispatchGroup.init()
            for url in urls {
                group.enter()
                os_log("Data fetch request started for URL '%@'", log: RemoteDataFetcher.logger, type: .debug, url.absoluteString)
                urlSession.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                    self?.handleNetworkResponse(data: data, response: response, error: error, dispatchGroup: group)
                }).resume()
            }

            self?.waitForFinishAllFetches(withGroup: group)
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

    func waitForFinishAllFetches(withGroup group: DispatchGroup) {
        group.notify(queue: dispatchQueue) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.errors.count > 0 {
                strongSelf.delegate?.remoteDataFetchRequestFailed(errors: strongSelf.errors)
                return
            }

            if strongSelf.datas.count != 2 {
                os_log("Unexpected number of data objects '%d'",
                       log: RemoteDataFetcher.logger,
                       type: .error,
                       strongSelf.datas.count)
            }

            if strongSelf.responses.count != 2 {
                os_log("Unexpected number of response objects '%d'",
                       log: RemoteDataFetcher.logger,
                       type: .error,
                       strongSelf.datas.count)
            }

            strongSelf.delegate?.remoteDataFetchRequestSuccess(datas: strongSelf.datas, responses: strongSelf.responses)

        }
    }
}


