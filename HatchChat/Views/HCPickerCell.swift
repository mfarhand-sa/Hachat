//
//  HCChipCell.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-05.
//


import UIKit

class HCChipCell: UICollectionViewCell {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = .HCCellBackground

        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        titleLabel.font = .CDFontSemiBold(size: 14)

        
        titleLabel.textColor = .HCMainLabel
        titleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0


        subtitleLabel.font = .CDFontRegular(size: 12)
        subtitleLabel.textColor = .HCSecondaryLabel
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0


        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
