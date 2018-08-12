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

    var employee: Employee? {
        didSet {
            employeeNameLabel.text = "\(employee?.firstName ?? "") \(employee?.lastName ?? "")"
            positionLabel.text = employee?.position?.rawValue
            if employee?.contactsCardIdentifier != nil {
                contactCardButton.isHidden = false
            }
            else {
                contactCardButton.isHidden = true
            }
        }
    }

    weak var delegate: EmployeeTableViewCellDelegate?

    // UI
    private let employeeNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let positionLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        label.textColor = .lightGray
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
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITableViewCell methods -

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Private methods -

    func setupViews() {
        contentView.addSubview(employeeNameLabel)
        contentView.addSubview(positionLabel)
        contentView.addSubview(contactCardButton)

        let safeArea = contentView.safeAreaLayoutGuide

        contactCardButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        contactCardButton.widthAnchor.constraint(equalTo: contactCardButton.heightAnchor).isActive = true
        contactCardButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true
        contactCardButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        employeeNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        employeeNameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16).isActive = true

        positionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        positionLabel.leadingAnchor.constraint(equalTo: employeeNameLabel.leadingAnchor).isActive = true
        employeeNameLabel.firstBaselineAnchor.constraint(equalTo: positionLabel.firstBaselineAnchor, constant: -32).isActive = true

        contactCardButton.isHidden = true
        contactCardButton.addTarget(self, action: #selector(contactCardButtonAction), for: .touchUpInside)
    }

    @objc func contactCardButtonAction(sender: UIButton) {
        delegate?.contactCardButtonTapped(sender: self)
    }
}
