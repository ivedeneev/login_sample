//
//  FavoriteDestinationCell.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import UIKit
import IVCollectionKit

final class FavoriteDestinationCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = .white
        iconImageView.layer.cornerRadius = 20
    }
}

extension FavoriteDestinationCell: ConfigurableCollectionItem {
    static func estimatedSize(item: Address, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        CGSize(width: 72, height: 62)
    }
    
    func configure(item: Address) {
//        iconImageView.image = UIImage(named: item)
        titleLabel.text = item.name
    }
}
