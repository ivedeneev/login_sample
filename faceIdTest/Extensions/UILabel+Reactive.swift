//
//  UILabel+Reactive.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 08.06.2021.
//

import UIKit
import RxSwift

extension Reactive where Base: UILabel {
    var animatedText: Binder<String> {
        Binder(base) { (label, text) in
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(
                name: CAMediaTimingFunctionName.easeInEaseOut
            )
            animation.type = CATransitionType.push
            animation.duration = 0.2
            label.layer.add(animation, forKey: CATransitionType.fade.rawValue)
            label.text = text

        }
    }
}
