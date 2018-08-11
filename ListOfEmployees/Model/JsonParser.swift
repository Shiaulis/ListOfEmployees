//
//  JsonParser.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation

protocol JsonParserDelegate: class {
    func parsingFinishedSuccessfully(employees: [EmployeeCodable], initialData: Data)
    func parsingFinishedWithError(error: Error)
}

class JsonParser {

    // MARK: - Properties -

    private let dispatchQueue: DispatchQueue
    private let decoder: JSONDecoder
    weak var delegate: JsonParserDelegate?

    // MARK: - Initialization -

    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
        self.decoder = JSONDecoder.init()
    }

    func parse(data: Data) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else {
                assertionFailure("Unexpected nil self")
                // FIXME: generate error
                return
            }

            do {
                let employeesCodable = try strongSelf.decoder.decode(EmployeesCodable.self, from: data)
                strongSelf.delegate?.parsingFinishedSuccessfully(employees: employeesCodable.employees, initialData: data)
            }
            catch {
                // FIXME: catch error
            }
        }
    }
}

struct EmployeesCodable: Decodable {
    let employees: [EmployeeCodable]
}

struct EmployeeCodable: Decodable {
    let firstName: String?
    let lastName: String?
    let position: EmployeePosition?
    let contactDetails: ContactDetails?
    let projects: [String]?

    enum CodingKeys: String, CodingKey {
        case firstName = "fname"
        case lastName = "lname"
        case position
        case contactDetails = "contact_details"
        case projects
    }
}

enum EmployeePosition: String, Decodable {
    case ios = "IOS"
    case pm = "PM"
    case other = "OTHER"
    case web = "WEB"
    case android = "ANDROID"
    case sales = "SALES"
    case tester = "TESTER"
}

struct ContactDetails: Decodable {
    let email: String?
    let phone: String?
}
