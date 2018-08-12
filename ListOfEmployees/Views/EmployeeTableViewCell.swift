//
//  EmployeeTableViewCell.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 12.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    // MARK: - Properties -

    private let employeeNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "EMPLOYEE"
        return label
    }()

    private let positionLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TEST"
        return label
    }()

    private let contactButtonView: UIButton = {
        let button = UIButton.init(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "AddressBookButtonIcon"), for: .normal)
        button.tintColor = .blue
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
        contentView.addSubview(contactButtonView)

        let safeArea = contentView.safeAreaLayoutGuide

        contactButtonView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        contactButtonView.widthAnchor.constraint(equalTo: contactButtonView.heightAnchor).isActive = true
        contactButtonView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true
        contactButtonView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        employeeNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        employeeNameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16).isActive = true

        positionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        positionLabel.leadingAnchor.constraint(equalTo: employeeNameLabel.leadingAnchor).isActive = true
        employeeNameLabel.firstBaselineAnchor.constraint(equalTo: positionLabel.firstBaselineAnchor, constant: -32).isActive = true

    }
}
