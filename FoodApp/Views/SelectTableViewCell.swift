//
//  SelectTableViewCell.swift
//  FoodApp
//
//  Created by Timmy Nguyen on 3/5/24.
//

import UIKit

class SelectTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SelectCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Set image width & height
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])
        return imageView
    }()
    
    var primaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    var secondaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .right
        return label
    }()

    var container: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        iconContainer.addSubview(iconImageView)
        container.addArrangedSubview(iconContainer)
        container.addArrangedSubview(primaryLabel)
        container.addArrangedSubview(secondaryLabel)
        
        contentView.addSubview(container)
                
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: iconContainer.topAnchor, constant: 4),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: -4),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: 4),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: -4)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(primaryText: String, secondaryText: String?, image: UIImage?, bgColor: UIColor?) {
        primaryLabel.text = primaryText
        secondaryLabel.text = secondaryText
        iconImageView.image = image
        iconContainer.backgroundColor = bgColor
        accessoryType = .disclosureIndicator
    }
}
