//
//  ProfileHeaderCell.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 05.02.2021.
//

import UIKit

final class ProfileHeaderCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let phoneLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(nameLabel)
        addSubview(phoneLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            phoneLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: -2),
        ])
        
        nameLabel.font = Font.profileName
        nameLabel.textColor = Color.text()
        
        phoneLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        phoneLabel.textColor = Color.secondaryText()
    }
}

extension ProfileHeaderCell: ConfigurableCollectionItem {
    static func estimatedSize(item: User, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        CGSize(width: boundingSize.width, height: 80)
    }
    
    func configure(item: User) {
        nameLabel.text = item.name
        phoneLabel.text = item.phone.formattedNumber(mask: "+X (XXX) XXX-XX-XX")
    }
}
