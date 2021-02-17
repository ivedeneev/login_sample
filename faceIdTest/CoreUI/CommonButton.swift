//
//  CommonButton.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 06.02.2021.
//

import UIKit

enum ActionStyle {
    case primary
    case `default`
    
    var backgroundColor: UIColor {
        switch self {
        case .`default`:
            return Color.background()
        case .primary:
            return Color.accent()
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .`default`:
            return Color.text()
        case .primary:
            return UIColor.white
        }
    }
}

final class CommonButton: UIButton {
    
    var style = ActionStyle.primary {
        didSet {
            configureStyle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        configureStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        configureStyle()
    }
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? style.backgroundColor : Color.secondaryBackground()
            setupShadowColor()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? style.backgroundColor.highlighted : style.backgroundColor
            setupShadowColor()
        }
    }
    
    private func setup() {
        let font = Font.listItemTitle
        titleLabel?.font = font
    }
    
    private func configureStyle() {
        backgroundColor = style.backgroundColor
        setTitleColor(style.textColor, for: .normal)
        tintColor = style.textColor
        layer.cornerRadius = 6
//        layer.cornerRadius = 4
//        layer.shadowOpacity = 0.4
//        layer.shadowOffset = CGSize(width: 2, height: 2)
//        layer.shadowRadius = 10
        setupShadowColor()
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
    
    private func setupShadowColor() {
//        switch style {
//        case .default:
//            switch traitCollection.userInterfaceStyle {
//            case .dark:
//                layer.shadowColor = UIColor.clear.cgColor
//            default:
//                layer.shadowColor = Color.gray.cgColor
//            }
//
//        default:
//            layer.shadowColor = backgroundColor?.cgColor
//        }
    }
}

