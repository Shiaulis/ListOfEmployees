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
                    let parsedEmployees = try strongSelf.decoder.decode(EmployeesCodable.self, from: data).employees
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

struct EmployeesCodable: Decodable {
    let employees: [Employee]
}

struct Employee: Decodable {
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

extension Employee: Comparable {
    static func < (lhs: Employee, rhs: Employee) -> Bool {

        guard let leftLastName = lhs.lastName, let rightLastName = rhs.lastName else {
            return lhs.lastName == nil && rhs.lastName == nil
        }

        if leftLastName != rightLastName {
            return leftLastName < rightLastName
        }

        guard let leftFirstName = lhs.firstName, let rightFirstName = rhs.firstName else {
            return lhs.firstName == nil && rhs.firstName == nil
        }

        return leftFirstName < rightFirstName
    }
}

extension Employee: Equatable {
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        if lhs.lastName != rhs.lastName {
            return lhs.lastName == rhs.lastName
        }
        return lhs.firstName == rhs.firstName
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
