//
//  Errors.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation

enum ApplicationModelError: Error {
    case dataFetchError
}

extension ApplicationModelError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataFetchError:
            return NSLocalizedString("Failed to fetch data from remote server", comment: "error description")
        }
    }
}

enum PersistentCacheStorageError: Error {
    case createCacheDirectoryURLError
}

extension PersistentCacheStorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .createCacheDirectoryURLError:
            return NSLocalizedString("Failed to initiate cache directory", comment: "error description")
        }
    }

}
