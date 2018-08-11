//
//  Extentions.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import Foundation
import os.log

enum LogSubsystem: String {
    case applicationModel = "com.shiaulis.ListOfEmployees.applicationModel"
}

extension OSLog {
    convenience init(subsystem: LogSubsystem, object: Any) {
        self.init(subsystem: subsystem.rawValue, category: String(describing: object))
    }
}

extension Notification.Name {
    static let didUpdateEmployees = Notification.Name.init("DidUpdateEmployees")
}
