//
//  Employee.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation

struct Employee: Decodable {
    let firstName: String?
    let lastName: String?
    let position: EmployeePosition?
    let contactDetails: ContactDetails?
    let projects: [String]?

    var contactsCardIdentifier: String?
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }

    enum CodingKeys: String, CodingKey {
        case firstName = "fname"
        case lastName = "lname"
        case position
        case contactDetails = "contact_details"
        case projects
        case contactsCardIdentifier
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
