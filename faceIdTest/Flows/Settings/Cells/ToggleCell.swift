//
//  ToggleCell.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 26.02.2021.
//

import UIKit
import RxSwift
import RxRelay

final class ToggleCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let `switch` = UISwitch()
    private let iconImageView = UIImageView()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        let stackView = UIStackView()
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(`switch`)
        
        stackView.frame = frame
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            iconImageView.widthAnchor.constraint(equalToConstant: 40),
//            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        titleLabel.setContentCompressionResistancePriority(.init(251), for: .horizontal)
        titleLabel.setContentHuggingPriority(.init(249), for: .horizontal)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}

extension ToggleCell: ConfigurableCollectionItem {
    func configure(item: ToggleCellViewModel) {
        titleLabel.text = item.title
        iconImageView.isHidden = item.icon == nil
        
        `switch`.isOn = item.isOnRelay.value
        `switch`.rx.isOn.bind(to: item.isOnRelay).disposed(by: disposeBag)
        item.isOnRelay.bind(to: `switch`.rx.isOn).disposed(by: disposeBag)
    }
    
    static func estimatedSize(item: ToggleCellViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        CGSize(width: boundingSize.width, height: 51)
    }
}

final class ToggleCellViewModel {
    let title: String
    let icon: String?
    let isOnRelay: BehaviorRelay<Bool>
    
    init(title: String, icon: String? = nil, isOn: Bool) {
        self.title = title
        self.icon = icon
        isOnRelay = .init(value: isOn)
    }
}
