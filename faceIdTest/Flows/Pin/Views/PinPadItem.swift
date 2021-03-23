//
//  PinPadItem.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 18.02.2021.
//

import UIKit
import RxSwift

let pinPadButtonSize = 60

final class PinPadItem: UIControl {
    
    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }
    
    var digit: Int? {
        didSet {
            guard let d = digit else { return }
            digitLabel.text = d.description
            clipsToBounds = true
            layer.cornerRadius = 30
        }
    }
    
    private let digitLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: pinPadButtonSize, height: pinPadButtonSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Color.lightBlueGray()
        
        digitLabel.textColor = Color.text()
        digitLabel.textAlignment = .center
        digitLabel.font = .systemFont(ofSize: 24, weight: .medium)
        
        addSubview(digitLabel)
        addSubview(iconImageView)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = Color.text()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        digitLabel.frame = bounds
        iconImageView.frame = bounds
    }
    
    class func itemWithDigit(_ digit: Int) -> PinPadItem {
        let item = PinPadItem()
        item.digit = digit
        return item
    }
    
    class func itemWithIcon(_ icon: UIImage?) -> PinPadItem {
        let item = PinPadItem()
        item.icon = icon
        return item
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
