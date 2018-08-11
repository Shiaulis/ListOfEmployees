//
//  RemoteDataFether.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation

protocol RemoteDataFetcherDelegate: class {
    func remoteDataFetchRequestSuccess(data: Data, response: URLResponse)
    func remoteDataFetchRequestFailed(error: Error)
}

class RemoteDataFetcher: NSObject {

    // MARK: - Properties -

    weak var delegate: RemoteDataFetcherDelegate?
    private let urlSession: URLSession
    private let dispatchQueue: DispatchQueue

    // MARK: - Initialization -

    init(with urlSession: URLSession, dispatchQueue: DispatchQueue) {
        self.urlSession = urlSession
        self.dispatchQueue = dispatchQueue
        super.init()
    }

    // MARK: - Public methods

    func startFetchData(from url:URL) {
        dispatchQueue.async { [weak self] in
            assert(self != nil)
            self?.urlSession.dataTask(with: url) { [weak self] (data, response, error) in
                guard let strongSelf = self else {
                    return
                }

                if let error = error {
                    strongSelf.delegate?.remoteDataFetchRequestFailed(error: error)
                    return
                }

                guard let data = data else {
                    assertionFailure("Data expected to exist")
                    return
                }

                guard let response = response else {
                    assertionFailure("Response expected to exist")
                    return
                }

                strongSelf.delegate?.remoteDataFetchRequestSuccess(data: data, response: response)
                }.resume()
        }
    }

}


