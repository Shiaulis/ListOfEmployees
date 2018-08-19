//
//  PersistentCacheStorage.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import os.log

protocol PersistentCacheStorageDelegate: class {
    func cachingDataFailed(withError: Error?)
    func cachingDataSucceeded()
    func cachedDataIsReadedSuccessfully(dataObjects: [Data])
    func cachedDataReadingFailed(withError: Error?)
}

class PersistentCacheStorage {

    // MARK: - Properties -
    static private let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: PersistentCacheStorage.self)

    // Public
    weak var delegate: PersistentCacheStorageDelegate?
    // Simple bool flag that shows whether data in cache ready to be read
    var isDataCached: Bool
    // Private
    private let dispatchQueue: DispatchQueue
    private let systemFileManager: FileManager
    private let destinationCacheDirectoryURL: URL

    // MARK: - Initialization -

    init(directoryName: String, queue: DispatchQueue) throws {
        self.systemFileManager = FileManager.default
        let cachesDirectoryURL = try PersistentCacheStorage.getCachesDirectoryURL()
        self.destinationCacheDirectoryURL = cachesDirectoryURL.appendingPathComponent(directoryName, isDirectory: true)

        if (self.systemFileManager.fileExists(atPath: self.destinationCacheDirectoryURL.path) == false) {
            try self.systemFileManager.createDirectory(at: self.destinationCacheDirectoryURL,
                                                       withIntermediateDirectories: true,
                                                       attributes: nil)
            self.isDataCached = false
        }
        else {
            self.isDataCached = true
        }

        self.dispatchQueue = queue

    }

    // MARK: - Public methods -

    func cache(dataObjects: [Data]) {
        self.isDataCached = false
        dispatchQueue.sync { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }

            do {
                try strongSelf.cleanCacheDirectory()

                for (index, data) in dataObjects.enumerated() {
                    let fileName = "data\(index)"
                    let url = strongSelf.destinationCacheDirectoryURL.appendingPathComponent(fileName)
                    try data.write(to: url)
                    os_log("Data successfully cached at path '%@'", log: PersistentCacheStorage.logger, type: .debug, url.path)
                }
                strongSelf.delegate?.cachingDataSucceeded()
                strongSelf.isDataCached = true
            }
            catch {
                os_log("Failed to cache data. Error '%@'", log: PersistentCacheStorage.logger, type: .error, error.localizedDescription)
                strongSelf.delegate?.cachingDataFailed(withError: error)
            }
        }
    }

    func startReadingCacheData() {
        dispatchQueue.sync { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }

            do {
                let contents = try strongSelf.systemFileManager.contentsOfDirectory(at: strongSelf.destinationCacheDirectoryURL,
                                                                                    includingPropertiesForKeys: nil,
                                                                                    options:.skipsHiddenFiles)
                var dataObjects: [Data] = []
                for itemURL in contents {
                    let data = try Data.init(contentsOf: itemURL)
                    dataObjects.append(data)
                }
                strongSelf.delegate?.cachedDataIsReadedSuccessfully(dataObjects: dataObjects)
            }
            catch {
                strongSelf.delegate?.cachedDataReadingFailed(withError: error)
            }
        }
    }

    // MARK: - Private methods -

    private func cleanCacheDirectory() throws {
        try cleanDirectory(url: self.destinationCacheDirectoryURL)
        self.isDataCached = false
    }

    private func cleanDirectory(url: URL) throws {
        let contents = try self.systemFileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options:.skipsHiddenFiles)
        for itemURL in contents {
            try self.systemFileManager.removeItem(at: itemURL)
        }
    }

    private static func getCachesDirectoryURL() throws -> URL {
        guard let libraryDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            assertionFailure()
            throw PersistentCacheStorageError.createCacheDirectoryURLError
        }

        return libraryDirectoryURL.appendingPathComponent("Caches", isDirectory: true)
    }
}
