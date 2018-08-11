//
//  PersistentStorage.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation

class PersistentStorage {

    // MARK: - Properties -

    private let dispatchQueue: DispatchQueue
    private let fileManager: FileManager
    private let documentsDirectoryURL: URL

    // MARK: - Initialization -

    init?(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
        self.fileManager = FileManager.default
        guard let documentsDirectoryURL = PersistentStorage.getDocumentsDirectoryURL() else {
            // FIXME: error
            return nil
        }
        self.documentsDirectoryURL = documentsDirectoryURL
    }

    // MARK: - Public methods -

    func cache(data: Data, withName name: String) {
        dispatchQueue.async { [weak self] in

            guard let strongSelf = self else {
                // FIXME: produce error
                return
            }
            let targetURL = strongSelf.documentsDirectoryURL.appendingPathComponent(name)
            do {
                if (strongSelf.fileManager.fileExists(atPath: targetURL.path)) {
                    try strongSelf.fileManager.removeItem(at: targetURL)
                }

                try data.write(to: targetURL)
            }
            catch {
                // FIXME: produce error
            }
        }
    }

    func dataFromCache(withName: String) -> Data? {
        return nil
    }

    // MARK: - Private methods -

    private static func getDocumentsDirectoryURL() -> URL? {
        let documentsDirectoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        assert(documentsDirectoryURLs.count == 1, "Is there any change to see other than 1 value in this array?")
        return documentsDirectoryURLs.first
    }
}
