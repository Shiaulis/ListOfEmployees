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
    case stringToURLConvertError(String)
}

extension ApplicationModelError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataFetchError:
            return NSLocalizedString("Failed to fetch data from remote server", comment: "error description")
        case .stringToURLConvertError(let failedURLString):
            return NSLocalizedString("Failed to get URL from string \(failedURLString)", comment: "error description")
        }
    }
}

enum PersistentCacheStorageError: Error {
    case createCacheDirectoryURLError
}
