//
//  CommonCell.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 05.02.2021.
//

import UIKit

struct CommonCellViewModel: Hashable {
    let title: String
    let subtitle: String?
    let icon: String?
}

final class CommonCell: UICollectionViewCell {
    
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.secondaryBackground() : Color.background()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(stackView)
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
        ])
        
        stackView.setCustomSpacing(12, after: iconImageView)
        iconImageView.contentMode = .center
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(iconImageView)
        
        let titlesVStack = UIStackView()
        titlesVStack.spacing = 0
        titlesVStack.axis = .vertical
        titlesVStack.addArrangedSubview(titleLabel)
        titlesVStack.addArrangedSubview(subtitleLabel)
        titlesVStack.distribution = .equalCentering
        titlesVStack.alignment = .leading
        
        titleLabel.textColor = Color.text()
        titleLabel.font = Font.listItemTitle
        
        subtitleLabel.textColor = Color.secondaryText()
        subtitleLabel.font = Font.listItemSubtitle
        
        stackView.addArrangedSubview(titlesVStack)
    }
}

extension CommonCell : ConfigurableCollectionItem {
    static func estimatedSize(item: CommonCellViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        CGSize(width: boundingSize.width, height: 52)
    }
    
    func configure(item: CommonCellViewModel) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
//        iconImageView.isHidden = item.icon == nil
        if let icon = item.icon {
            iconImageView.image = UIImage(named: icon)
        } else {
            iconImageView.image = nil
        }
    }
}
