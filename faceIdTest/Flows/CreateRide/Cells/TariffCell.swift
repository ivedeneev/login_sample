//
//  TariffCell.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import UIKit
import IVCollectionKit

struct TariffCellViewModel {
    let title: String
    let price: String
    let icon: String
    
    init(tariff: Tariff) {
        self.title = tariff.title
        self.price = "\(tariff.price) Р"
        self.icon = "bentley"
    }
}

final class TariffCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.selectedTariff() : Color.background()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(priceLabel)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            priceLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: priceLabel.topAnchor, constant: 4),
        ])
        
        layer.cornerRadius = 8
        iconImageView.contentMode = .scaleAspectFit
        priceLabel.font = Font.tariffPrice
        titleLabel.textColor = Color.secondaryText()
        titleLabel.font = Font.tariffTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TariffCell: ConfigurableCollectionItem {
    static func estimatedSize(item: TariffCellViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        CGSize(width: 95, height: 90)
    }
    
    func configure(item: TariffCellViewModel) {
        titleLabel.text = item.title
        priceLabel.text = item.price
        iconImageView.image = UIImage(named: item.icon)
    }
}
