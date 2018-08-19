//
//  EmployeeTableViewCell.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 12.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

protocol EmployeeTableViewCellDelegate: class {
    func contactCardButtonTapped(sender: EmployeeTableViewCell)
}

class EmployeeTableViewCell: UITableViewCell {

    // MARK: - Properties -

    // Data
    var title: String? {
        didSet {
            employeeNameLabel.text = title
        }
    }

    var shouldPresentContactCardButton: Bool {
        didSet {
            // This expression also can be written as just
            // contactCardButton.isHidden = ! shouldPresentContactCardButton
            // but this form looks more clear for me
            if shouldPresentContactCardButton {
                contactCardButton.isHidden = false
            }
            else {
                contactCardButton.isHidden = true
            }
        }
    }

    weak var contactButtonDelegate: EmployeeTableViewCellDelegate?

    // UI
    private let employeeNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let contactCardButton: UIButton = {
        let button = UIButton.init(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "AddressBookButtonIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization -

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.shouldPresentContactCardButton = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods -

    private func setupViews() {
        contentView.addSubview(employeeNameLabel)
        contentView.addSubview(contactCardButton)

        contactCardButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        contactCardButton.widthAnchor.constraint(equalTo: contactCardButton.heightAnchor).isActive = true
        contactCardButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        contactCardButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        employeeNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        employeeNameLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true

        contactCardButton.addTarget(self, action: #selector(contactCardButtonAction), for: .touchUpInside)
    }

    @objc private func contactCardButtonAction(sender: UIButton) {
        contactButtonDelegate?.contactCardButtonTapped(sender: self)
    }
}
