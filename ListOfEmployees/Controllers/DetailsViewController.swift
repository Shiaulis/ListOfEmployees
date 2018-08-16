//
//  DetailsViewController.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 16.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    private let employee: Employee
    weak var contactViewControllerProvider: ContactViewControllerProvider?

    private lazy var imageView: UIImageView = {
        let imaveView = UIImageView.init(image: #imageLiteral(resourceName: "PersonIcom"))
        imaveView.contentMode = .scaleAspectFit
        imaveView.translatesAutoresizingMaskIntoConstraints = false
        return imaveView
    }()

    private lazy var personNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contactButton: UIButton = {
        let button = UIButton.init(type: UIButtonType.roundedRect)
        button.tintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Contact card", comment: "contact card button caption in details view"),
                        for: UIControlState.normal)
        return button
    }()

    init(withEmployee employee: Employee) {
        self.employee = employee
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Because the CNContactViewController has different tint color
        // we should return it back to white
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    }

    private func setupViews() {


        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true

        personNameLabel.text = employee.fullName
        view.addSubview(personNameLabel)
        personNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        personNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        personNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true

        // Bottom view is used to show the lowest view which can be used for
        // creating proper constraint
        var lowestView: UIView = personNameLabel

        if let position = employee.position {
            positionLabel.text = position.description
            view.addSubview(positionLabel)
            positionLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor).isActive = true
            positionLabel.trailingAnchor.constraint(equalTo: personNameLabel.trailingAnchor).isActive = true
            positionLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8).isActive = true
            lowestView = positionLabel
        }

        if employee.contactsCardIdentifier != nil  {
            view.addSubview(contactButton)
            contactButton.addTarget(self, action: #selector(contactButtonAction), for: .touchUpInside)
            contactButton.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: 8).isActive = true
            contactButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            contactButton.heightAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.7).isActive = true
            lowestView = contactButton
        }

        if let email = employee.contactDetails?.email {
            let emailView = ContactDetailView.init(contactType: NSLocalizedString("email", comment: "contact type in details view"),
                                                 value: email)
            view.addSubview(emailView)
            emailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            emailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            emailView.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: 24).isActive = true
            emailView.backgroundColor = .green
            lowestView = emailView
        }

        if let phone = employee.contactDetails?.phone {
            let phoneView = ContactDetailView.init(contactType: NSLocalizedString("phone", comment: "contact type in details view"),
                                                   value: phone)
            view.addSubview(phoneView)
            phoneView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            phoneView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            phoneView.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: 24).isActive = true
            phoneView.backgroundColor = .yellow
            lowestView = phoneView
        }



        view.backgroundColor = .white
    }

    @objc private func contactButtonAction() {
        contactViewControllerProvider?.openContactViewController(for: employee)
    }
}

private class ContactDetailView: UIView {

    private let contactType: String
    private let contactValue: String

    private lazy var contactTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK:- Initialization -

    init(contactType: String, value: String) {
        self.contactType = contactType
        self.contactValue = value
        super.init(frame: .zero)
        backgroundColor = .red
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private methods
    private func setupViews() {
        addSubview(contactTypeLabel)
        contactTypeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        contactTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8).isActive = true

        addSubview(valueLabel)
        valueLabel.leadingAnchor.constraint(equalTo: contactTypeLabel.leadingAnchor).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: contactTypeLabel.trailingAnchor).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}
