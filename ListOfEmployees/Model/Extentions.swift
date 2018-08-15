//
//  Extentions.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 11.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit
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
    static let employeesListDidChangeExternally = Notification.Name.init("employeesListDidChangeExternally")
}

extension UIView {
    func addConstraints(withVisualFormat visualFormat: String, views: UIView...) {
        var viewsDictionary: Dictionary<String, UIView> = [:]
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
