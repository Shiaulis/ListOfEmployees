//
//  EmployeeDetailsViewController.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 16.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class EmployeeDetailsViewController: UIViewController {

    private static let ofset: CGFloat = 24.0

    private let employee: Employee
    weak var contactViewControllerProvider: ContactViewControllerProvider?

    private lazy var personImageView: UIImageView = {
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


        view.addSubview(personImageView)
        personImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        personImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        personImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true
        personImageView.widthAnchor.constraint(equalTo: personImageView.heightAnchor).isActive = true

        personNameLabel.text = employee.fullName
        view.addSubview(personNameLabel)
        personNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        personNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        personNameLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8).isActive = true

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

        addSeparator(lowestView: &lowestView, distanceFromLowestView: 8)

        if let email = employee.contactDetails?.email {
            addContactDetailAsSubview(contactTypeName: NSLocalizedString("email", comment: "contact detail type"),
                                      contactValue: email,
                                      lowestView: &lowestView)
        }

        if let phone = employee.contactDetails?.phone {
            addContactDetailAsSubview(contactTypeName: NSLocalizedString("phone", comment: "contact detail type"),
                                      contactValue: phone,
                                      lowestView: &lowestView)
        }

        addSeparator(lowestView: &lowestView, distanceFromLowestView: 8)

        if let projects = employee.projects, projects.count > 0 {
            addProjectsViews(projects: projects, lowestView: &lowestView, distanceFromLowestView: 8)
        }

        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9764705882, blue: 1, alpha: 1)
    }

    @objc private func contactButtonAction() {
        contactViewControllerProvider?.openContactViewController(for: employee)
    }

    // This method add contact details:
    // email
    // test@test.com
    // Lowest view is inout parameter. After method execution it will be
    // referenced to the lowest added view
    private func addContactDetailAsSubview(contactTypeName: String,
                                           contactValue: String, lowestView:inout UIView) {
        let contactTypeNameLabel = UILabel()
        contactTypeNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)
        contactTypeNameLabel.numberOfLines = 1
        contactTypeNameLabel.textAlignment = .left
        contactTypeNameLabel.translatesAutoresizingMaskIntoConstraints = false

        contactTypeNameLabel.text = contactTypeName

        view.addSubview(contactTypeNameLabel)
        contactTypeNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: EmployeeDetailsViewController.ofset).isActive = true
        contactTypeNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -EmployeeDetailsViewController.ofset).isActive = true
        contactTypeNameLabel.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: 24).isActive = true

        let contactValueLabel = UILabel()
        contactValueLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        contactValueLabel.numberOfLines = 1
        contactValueLabel.adjustsFontSizeToFitWidth = true
        contactValueLabel.minimumScaleFactor = 0.5
        contactValueLabel.textAlignment = .left
        contactValueLabel.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        contactValueLabel.translatesAutoresizingMaskIntoConstraints = false

        contactValueLabel.text = contactValue

        view.addSubview(contactValueLabel)
        contactValueLabel.leadingAnchor.constraint(equalTo: contactTypeNameLabel.leadingAnchor).isActive = true
        contactValueLabel.trailingAnchor.constraint(equalTo: contactTypeNameLabel.trailingAnchor).isActive = true
        contactValueLabel.topAnchor.constraint(equalTo: contactTypeNameLabel.bottomAnchor, constant: 4).isActive = true

        lowestView = contactValueLabel
    }

    func addSeparator(lowestView: inout UIView, distanceFromLowestView: CGFloat) {
        let lineView = UIView.init(frame: .zero)
        lineView.backgroundColor = .gray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineView)
        lineView.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
        lineView.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: distanceFromLowestView).isActive = true
        lineView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: EmployeeDetailsViewController.ofset).isActive = true
        lineView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -EmployeeDetailsViewController.ofset).isActive = true
    }

    private func addProjectsViews(projects: [String], lowestView: inout UIView, distanceFromLowestView: CGFloat) {
        for project in projects {
            let currentProjectView = projectView(for: project)
            view.addSubview(currentProjectView)
            currentProjectView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: EmployeeDetailsViewController.ofset).isActive = true
            currentProjectView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -EmployeeDetailsViewController.ofset).isActive = true
            currentProjectView.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: distanceFromLowestView).isActive = true
            lowestView = currentProjectView

        }
    }

    private func projectView(for project: String) -> UIView {
        let projectView = UIView.init(frame: .zero)
        projectView.translatesAutoresizingMaskIntoConstraints = false

        let projectImageView = UIImageView.init(image: #imageLiteral(resourceName: "ProjectsIcom"))
        projectImageView.contentMode = .scaleAspectFit
        projectImageView.translatesAutoresizingMaskIntoConstraints = false

        projectView.addSubview(projectImageView)
        projectImageView.leadingAnchor.constraint(equalTo: projectView.leadingAnchor).isActive = true
        projectImageView.centerYAnchor.constraint(equalTo: projectView.centerYAnchor).isActive = true
        projectImageView.heightAnchor.constraint(equalTo: projectImageView.widthAnchor).isActive = true
        projectImageView.topAnchor.constraint(equalTo: projectView.topAnchor).isActive = true
        projectImageView.bottomAnchor.constraint(equalTo: projectView.bottomAnchor).isActive = true

        let projectNameLabel = UILabel.init(frame: .zero)
        projectNameLabel.text = project
        projectNameLabel.textAlignment = .left
        projectNameLabel.textColor = .black
        projectNameLabel.numberOfLines = 1
        projectNameLabel.adjustsFontSizeToFitWidth = true
        projectNameLabel.minimumScaleFactor = 0.5
        projectNameLabel.translatesAutoresizingMaskIntoConstraints = false

        projectView.addSubview(projectNameLabel)
        projectNameLabel.leadingAnchor.constraint(equalTo: projectImageView.trailingAnchor, constant: 16).isActive = true
        projectNameLabel.trailingAnchor.constraint(equalTo: projectView.trailingAnchor).isActive = true
//        projectNameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true

        projectView.topAnchor.constraint(equalTo: projectNameLabel.topAnchor, constant: -12).isActive = true
        projectView.bottomAnchor.constraint(equalTo: projectNameLabel.bottomAnchor, constant: 12).isActive = true

//        projectImageView.backgroundColor = .red
//        projectNameLabel.backgroundColor = .blue
//        projectView.backgroundColor = .yellow

        return projectView
    }
}
