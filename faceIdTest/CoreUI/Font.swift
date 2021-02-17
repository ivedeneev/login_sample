//
//  Font.swift
//  mycars-ios
//
//  Created by Igor Vedeneev on 4/1/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit.UIFont

final class Font {
    static var phone: UIFont = .systemFont(ofSize: 30)
    static var topMessage: UIFont = .systemFont(ofSize: 13)
    
    static var largeTitle: UIFont = .systemFont(ofSize: 40, weight: .heavy)
    static var title: UIFont = .systemFont(ofSize: 28, weight: .bold)
    static var title2: UIFont = .systemFont(ofSize: 16, weight: .regular)
    static var caption: UIFont = .systemFont(ofSize: 14)
    static var captionBold: UIFont = .systemFont(ofSize: 14, weight: .semibold)
    
    
    static var tariffTitle: UIFont = .systemFont(ofSize: 12, weight: .medium)
    static var tariffPrice: UIFont = .rounded(ofSize: 18, weight: .semibold)
    
    static var profileName: UIFont = .rounded(ofSize: 36, weight: .bold)
    
    static var listItemTitle: UIFont = .systemFont(ofSize: 18, weight: .semibold)
    static var listItemSubtitle: UIFont = .systemFont(ofSize: 12, weight: .regular)
    /// Код для авторзации
    static let code: UIFont = {
        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let bodyMonospacedNumbersFontDescriptor = bodyFontDescriptor.addingAttributes([
          UIFontDescriptor.AttributeName.featureSettings: [
            [UIFontDescriptor.FeatureKey.featureIdentifier:
             kNumberSpacingType,
             UIFontDescriptor.FeatureKey.typeIdentifier:
             kMonospacedNumbersSelector]
          ]
        ])
        
        return UIFont(descriptor: bodyMonospacedNumbersFontDescriptor, size: 30)
    }()
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
//            descriptor.addingAttributes([])
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}
