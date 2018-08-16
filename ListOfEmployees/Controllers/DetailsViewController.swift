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

    private lazy var imageView: UIImageView = {
        let imaveView = UIImageView.init(image: #imageLiteral(resourceName: "PersonIcom"))
        imaveView.contentMode = .scaleAspectFit
        imaveView.translatesAutoresizingMaskIntoConstraints = false
        return imaveView
    }()

    private lazy var personNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title3)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
//        label.minimumScaleFactor = 0.5
//        label.adjustsFontSizeToFitWidth = true
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

    override func viewDidLoad() {
        setupViews()
    }

    private func setupViews() {
        personNameLabel.text = employee.fullName

        view.addSubview(imageView)
        view.addSubview(personNameLabel)


        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        personNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        personNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        personNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true


        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        personNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true

        if employee.contactsCardIdentifier != nil  {
        view.addSubview(contactButton)
        contactButton.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8).isActive = true
        contactButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }

        view.backgroundColor = .white
    }
}
