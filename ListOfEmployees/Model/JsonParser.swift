//
//  JsonParser.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation

class JsonParser {

    // MARK: - Properties -

    private let dispatchQueue: DispatchQueue
    private let decoder: JSONDecoder

    // MARK: - Initialization -

    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
        self.decoder = JSONDecoder.init()
    }

    func parse(datas: [Data], completionHandler:@escaping (Error?, [Employee]?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else {
                assertionFailure()
                return
            }

            do {
                var employees: [Employee] = []
                for data in datas {
                    let parsedEmployees = try strongSelf.decoder.decode(Json.self, from: data).employees
                    employees.append(contentsOf: parsedEmployees)
                }

                completionHandler(nil, employees)
            }
            catch {
                completionHandler(error, nil)
            }
        }
    }
}

struct Json: Decodable {
    let employees: [Employee]
}


