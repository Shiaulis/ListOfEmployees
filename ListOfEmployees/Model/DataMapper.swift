//
//  JsonParser.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 10.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import Contacts
import os.log

class DataMapper {

    // MARK: - Properties -

    private let queue: DispatchQueue
    private let decoder: JSONDecoder
    private static let logger = OSLog.init(subsystem: LogSubsystem.applicationModel, object: DataMapper.self)

    // MARK: - Initialization -

    init(queue: DispatchQueue) {
        self.queue = queue
        self.decoder = JSONDecoder.init()
    }

    func parse(datas: [Data], usingContacts contactsStore: CNContactStore?, completionHandler:@escaping (Error?, [Employee]?) -> Void) {
        queue.async { [weak self] in
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

                if let contactsStore = contactsStore {
                    completionHandler(nil, strongSelf.fillEmployeesListWithContactsIdentifiers(employees: employees, contactsStore: contactsStore))
                }
                else {
                    completionHandler(nil, employees)
                }
            }
            catch {
                completionHandler(error, nil)
            }
        }
    }

    func contact(forIdentifier identifier: String, contactsStore:CNContactStore, keyDescriptor: CNKeyDescriptor, completionHandler:@escaping (CNContact?)->Void) {
        queue.async {
            do {
                let contact = try contactsStore.unifiedContact(withIdentifier: identifier, keysToFetch: [keyDescriptor])
                completionHandler(contact)
            }
            catch {
                os_log("Failed to find contact card. Error '%@'", log: DataMapper.logger, type: .error, error.localizedDescription)
                completionHandler(nil)
            }
        }
    }

    private func fillEmployeesListWithContactsIdentifiers(employees: [Employee], contactsStore: CNContactStore) -> [Employee] {
        var mutatedEmployees = employees;
        do {
            for index in 0..<employees.count {
                mutatedEmployees[index].contactsCardIdentifier = try getContactIdentifier(for: employees[index], from: contactsStore)
            }
            return mutatedEmployees
        }
        catch {
            os_log("Failed to parse match employees with contacts. Error '%@'", log: DataMapper.logger, type: .error, error.localizedDescription)
            return employees
        }
    }

    private func getContactIdentifier(for employee: Employee, from contactsStore: CNContactStore) throws -> String? {
        guard let firstName = employee.firstName else {
            assertionFailure()
            return nil
        }
        let predicate = CNContact.predicateForContacts(matchingName: firstName.lowercased())
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey]
        let contacts = try contactsStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
        for contact in contacts {
            if contact.familyName.lowercased() == employee.lastName?.lowercased() {
                return contact.identifier
            }
        }
        return nil
    }
}

private struct Json: Decodable {
    let employees: [Employee]
}
