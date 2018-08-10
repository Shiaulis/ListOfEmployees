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
    ["https://tallinn.jobapp.aw.ee/employee_list",
     "https://tartu.jobapp.aw.ee/employee_list"]

    // MARK: Private properties

    private let jsonParser: JsonParser
    private let remoteDataFetcher: RemoteDataFetcher

    // MARK: - Initialization -

    init() {
        self.jsonParser = JsonParser.init()
        self.remoteDataFetcher = RemoteDataFetcher.init()
    }

    // MARK: - Public methods -

    func startFetchingDataFromRemoteServerIfPossible() {

    }
}
