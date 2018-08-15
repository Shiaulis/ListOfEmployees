//
//  EmployeeDetailsViewCell.swift
//  ListOfEmployees
//
//  Created by Andrius Shiaulis on 15.08.2018.
//  Copyright © 2018 Andrius Shiaulis. All rights reserved.
//

import UIKit

class EmployeeDetailsViewCell: UITableViewCell {

    let cellImage: UIImage
    let cellTitle: String
    let cellCaption: String?

    init(image: UIImage, title: String, caption: String? = nil) {
        self.cellTitle = title
        self.cellImage = image
        self.cellCaption = caption
        super.init(style: .default, reuseIdentifier: nil)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {

        self.backgroundColor = .white

        let imageView = UIImageView.init(image: cellImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)

        let titleLabel = UILabel()
        titleLabel.text = self.cellTitle

        titleLabel.textColor = .black
        self.isUserInteractionEnabled = false

        if self.cellCaption != nil {
            titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        }
        else {
            titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)

        let captionLabel: UILabel?
        if let caption = self.cellCaption {
            let label = UILabel()
            label.text = caption
            label.textColor = .black
            label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)
            label.numberOfLines = 1
            label.minimumScaleFactor = 0.1
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = false
            captionLabel = label
            self.addSubview(label)
        }
        else {
            captionLabel = nil
        }

        imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 16.0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -30.0).isActive = true

        if let captionLabel = captionLabel {
            titleLabel.lastBaselineAnchor.constraint(equalTo: self.centerYAnchor, constant: -4).isActive = true

            captionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
            captionLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
            captionLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 3).isActive = true
        }
        else {
            titleLabel.firstBaselineAnchor.constraint(equalTo: self.centerYAnchor, constant: 4).isActive = true
        }
    }
}
