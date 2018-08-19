//
//  PlaceholderView.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 13.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class PlaceholderView: UILabel {

    // MARK: - Initialization -

    convenience init() {
        self.init(usingTitle: NSLocalizedString("The list is empty", comment: "placeholder text"))
    }

    init(usingTitle title: String) {
        super.init(frame: .zero)
        self.text = title
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods -

    private func setupView() {
        textAlignment = .center
        font = UIFont.preferredFont(forTextStyle: .title1)
        lineBreakMode = .byWordWrapping
        numberOfLines = 0
        textColor = UIColor.lightGray
    }
}
