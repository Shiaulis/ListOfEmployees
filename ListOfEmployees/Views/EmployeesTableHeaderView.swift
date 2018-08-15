//
//  EmployeesTableHeaderView.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 12.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class EmployeesTableHeaderView: UITableViewHeaderFooterView {

    // MARK: - Properties -

    // Data

    var headerTitle: String? {
        didSet {
            if let headerTitle = self.headerTitle {
                headerTitleLabel.text = String(headerTitle)
            }
        }
    }

    // UI
    private let headerTitleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization -

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    convenience init(withTitle title: String) {
        self.init(reuseIdentifier: nil)
        self.headerTitle = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods -

    func setupViews() {
        contentView.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        contentView.addSubview(headerTitleLabel)

        let safeArea = contentView.safeAreaLayoutGuide

        headerTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        headerTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        headerTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16).isActive = true
    }

}
