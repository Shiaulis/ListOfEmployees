//
//  EmployeeDetailsViewController.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 16.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class EmployeeDetailsViewController: UIViewController {


    // MARK: - Properties -
    // Resources
    // This offset is used to align all UI from leading and trailing borders on the same distance
    private static let offset: CGFloat = 24.0

    // Data
    private let employee: Employee
    weak var contactViewControllerProvider: ContactViewControllerProvider?

    // UI
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9764705882, blue: 1, alpha: 1)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    // We put all scrollable content in this view
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9764705882, blue: 1, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let personImageView: UIImageView = {
        let imaveView = UIImageView.init(image: #imageLiteral(resourceName: "PersonIcom"))
        imaveView.contentMode = .scaleAspectFit
        imaveView.translatesAutoresizingMaskIntoConstraints = false
        return imaveView
    }()

    private let personNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
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
        label.font = UIFont.preferredFont(forTextStyle: .body)
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
        button.setTitle(NSLocalizedString("Contact card", comment: "contact card button caption in details view"),
                        for: UIControlState.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var projectsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Projects", comment: "title for projects section")
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization -

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
        // we should return it back to global value
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        scrollView.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        containerView.addSubview(personImageView)
        personImageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        personImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        personImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true
        personImageView.widthAnchor.constraint(equalTo: personImageView.heightAnchor).isActive = true

        personNameLabel.text = employee.fullName
        containerView.addSubview(personNameLabel)
        personNameLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
        personNameLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
        personNameLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8).isActive = true

        // Bottom view is used to show the lowest view
        // which is used for creating proper constraint
        var lowestView: UIView = personNameLabel

        if let position = employee.position {
            positionLabel.text = position.description
            containerView.addSubview(positionLabel)
            positionLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor).isActive = true
            positionLabel.trailingAnchor.constraint(equalTo: personNameLabel.trailingAnchor).isActive = true
            positionLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 8).isActive = true
            lowestView = positionLabel
        }

        if employee.contactsCardIdentifier != nil  {
            containerView.addSubview(contactButton)
            contactButton.addTarget(self, action: #selector(contactButtonAction), for: .touchUpInside)
            contactButton.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: 8).isActive = true
            contactButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            contactButton.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 0.7).isActive = true
            lowestView = contactButton
        }

        if employee.contactDetails?.email != nil || employee.contactDetails?.phone != nil {
            // We won't add separator for case when there are no any contact details
            addSeparator(lowestView: &lowestView, distanceFromLowestView: 16)
        }

        if let email = employee.contactDetails?.email {
            addContactDetailAsSubview(to: containerView,
                                      contactTypeName: NSLocalizedString("email", comment: "contact detail type"),
                                      contactValue: email,
                                      lowestView: &lowestView,
                                      distanceFromLowestView: 16)
        }

        if let phone = employee.contactDetails?.phone {
            addContactDetailAsSubview(to: containerView,
                                      contactTypeName: NSLocalizedString("phone", comment: "contact detail type"),
                                      contactValue: phone,
                                      lowestView: &lowestView,
                                      distanceFromLowestView: 12)
        }

        if let projects = employee.projects, projects.count > 0 {
            addSeparator(lowestView: &lowestView, distanceFromLowestView: 16)

            containerView.addSubview(projectsSectionLabel)
            projectsSectionLabel.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: 16).isActive = true
            projectsSectionLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: EmployeeDetailsViewController.offset).isActive = true
            projectsSectionLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -EmployeeDetailsViewController.offset).isActive = true
            lowestView = projectsSectionLabel

            for project in projects {
                let currentProjectView = projectView(for: project)
                containerView.addSubview(currentProjectView)
                currentProjectView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: EmployeeDetailsViewController.offset).isActive = true
                currentProjectView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -EmployeeDetailsViewController.offset).isActive = true
                currentProjectView.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: 8).isActive = true
                lowestView = currentProjectView
            }
        }

        lowestView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
    }

    @objc private func contactButtonAction() {
        contactViewControllerProvider?.openContactViewController(for: employee)
    }

    private func addSeparator(lowestView: inout UIView, distanceFromLowestView: CGFloat) {
        let lineView = UIView.init(frame: .zero)
        lineView.backgroundColor = .gray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(lineView)
        lineView.heightAnchor.constraint(equalToConstant: 0.4).isActive = true
        lineView.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: distanceFromLowestView).isActive = true
        lineView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: EmployeeDetailsViewController.offset).isActive = true
        lineView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -EmployeeDetailsViewController.offset).isActive = true
        lowestView = lineView
    }


    // This method add contact details:
    // email
    // test@test.com
    // After method execution lowestView will reference to the lowest added view
    private func addContactDetailAsSubview(to containerView: UIView,
                                           contactTypeName: String,
                                           contactValue: String,
                                           lowestView:inout UIView,
                                           distanceFromLowestView: CGFloat) {
        let contactTypeNameLabel = UILabel()
        contactTypeNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)
        contactTypeNameLabel.numberOfLines = 1
        contactTypeNameLabel.textAlignment = .left
        contactTypeNameLabel.translatesAutoresizingMaskIntoConstraints = false

        contactTypeNameLabel.text = contactTypeName

        containerView.addSubview(contactTypeNameLabel)
        contactTypeNameLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: EmployeeDetailsViewController.offset).isActive = true
        contactTypeNameLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -EmployeeDetailsViewController.offset).isActive = true
        contactTypeNameLabel.topAnchor.constraint(equalTo: lowestView.bottomAnchor, constant: distanceFromLowestView).isActive = true

        let contactValueLabel = UILabel()
        contactValueLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        contactValueLabel.numberOfLines = 1
        contactValueLabel.adjustsFontSizeToFitWidth = true
        contactValueLabel.minimumScaleFactor = 0.5
        contactValueLabel.textAlignment = .left
        contactValueLabel.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        contactValueLabel.translatesAutoresizingMaskIntoConstraints = false

        contactValueLabel.text = contactValue

        containerView.addSubview(contactValueLabel)
        contactValueLabel.leadingAnchor.constraint(equalTo: contactTypeNameLabel.leadingAnchor).isActive = true
        contactValueLabel.trailingAnchor.constraint(equalTo: contactTypeNameLabel.trailingAnchor).isActive = true
        contactValueLabel.topAnchor.constraint(equalTo: contactTypeNameLabel.bottomAnchor, constant: 4).isActive = true

        lowestView = contactValueLabel
    }

    private func addProjectsViews(projects: [String], lowestView: inout UIView, distanceFromLowestView: CGFloat) {
    }

    private func projectView(for project: String) -> UIView {
        let projectView = UIView.init(frame: .zero)
        projectView.translatesAutoresizingMaskIntoConstraints = false

        let projectImageView = UIImageView.init(image: #imageLiteral(resourceName: "ProjectsIcom"))
        projectImageView.contentMode = .scaleAspectFill
        projectImageView.contentScaleFactor = 0.5
        projectImageView.translatesAutoresizingMaskIntoConstraints = false

        projectView.addSubview(projectImageView)

        let projectNameLabel = UILabel.init(frame: .zero)
        projectNameLabel.text = project
        projectNameLabel.textAlignment = .left
        projectNameLabel.textColor = .black
        projectNameLabel.numberOfLines = 1
        projectNameLabel.adjustsFontSizeToFitWidth = true
        projectNameLabel.minimumScaleFactor = 0.5
        projectNameLabel.translatesAutoresizingMaskIntoConstraints = false

        projectView.addSubview(projectNameLabel)

        projectImageView.leadingAnchor.constraint(equalTo: projectView.leadingAnchor).isActive = true
        projectImageView.centerYAnchor.constraint(equalTo: projectView.centerYAnchor).isActive = true

        projectImageView.heightAnchor.constraint(equalTo: projectImageView.widthAnchor).isActive = true
        projectImageView.topAnchor.constraint(equalTo: projectView.topAnchor).isActive = true
        projectImageView.bottomAnchor.constraint(equalTo: projectView.bottomAnchor).isActive = true


        projectNameLabel.leadingAnchor.constraint(equalTo: projectImageView.trailingAnchor, constant: 16).isActive = true
        projectNameLabel.trailingAnchor.constraint(equalTo: projectView.trailingAnchor).isActive = true

        projectView.topAnchor.constraint(equalTo: projectNameLabel.topAnchor, constant: -1).isActive = true
        projectView.bottomAnchor.constraint(equalTo: projectNameLabel.bottomAnchor, constant: 1).isActive = true

        return projectView
    }
}
