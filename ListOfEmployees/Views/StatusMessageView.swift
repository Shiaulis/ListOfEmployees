//
//  StatusMessageView.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 15.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

struct StatusMessageProperties {
    static let viewHeight: CGFloat = 30.0
    static let viewTimeAppearing = 3
}

enum MessageType {
    case progress, done, error
}

class StatusMessageView: UIView {

    // MARK: - Properties -

    private let messageView: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Initialization -
    init() {
        super.init(frame: .zero)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods -
    func show(message: String, type: MessageType) {

        switch type {
        case .progress:
            self.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            self.activityIndicator.startAnimating()
            self.messageView.text = message
        case .done:
            self.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            self.activityIndicator.stopAnimating()
            self.messageView.text = message
        case .error:
            self.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            self.activityIndicator.stopAnimating()
            self.messageView.text = message
        }
    }

    // MARK: - Private methods -

    private func setup() {
        self.addSubview(messageView)
        self.addSubview(activityIndicator)

        self.messageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.messageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.messageView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.8).isActive = true
        self.messageView.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, multiplier: 0.8).isActive = true

        self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.activityIndicator.rightAnchor.constraint(equalTo: self.messageView.leftAnchor, constant: -8).isActive = true
        self.activityIndicator.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, multiplier: 0.8).isActive = true
        self.activityIndicator.widthAnchor.constraint(equalTo: self.activityIndicator.heightAnchor).isActive = true

        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
