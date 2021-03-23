//
//  DotsField.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 18.02.2021.
//

import UIKit
import RxSwift

final class DotsField: UIView {
    var count: Int = 4
    var emptyColor: UIColor = .systemGray5
    var filledColor: UIColor = .systemBlue
    
    private var dots = [UIView]()
    private let spacing: Int = 12
    private let dotWidth: Int = 16
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: dotWidth * count + (count - 1) * spacing, height: dotWidth)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        for _ in 0..<count {
            let dot = UIView()
            dot.backgroundColor = emptyColor
            dot.clipsToBounds = true
            dot.layer.cornerRadius = CGFloat(dotWidth / 2)
            
            addSubview(dot)
            dots.append(dot)
        }
    }

    private func configureFilledDot(_ view: UIView) {
        view.backgroundColor = filledColor
    }

    private func configureEmptyDot(_ view: UIView) {
        view.backgroundColor = emptyColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for i in 0..<count {
            let x = i * dotWidth + i * spacing
            dots[i].frame = CGRect(x: x, y: 0, width: dotWidth, height: dotWidth)
        }
    }
    
    func fill(count: Int) {
        for i in 0..<self.count {
            let dot = dots[i]
            i < count ? configureFilledDot(dot) : configureEmptyDot(dot)
        }
    }
    
    func shakeOnError() {
        shake(duration: 0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.fill(count: 0)
        }
    }
}

extension Reactive where Base: DotsField {
    var numberOfFilledDots: Binder<Int> {
        Binder(base, binding: { view, count in
            view.fill(count: count)
        })
    }
    
    var error: Binder<Void> {
        Binder(base, binding: { view, _ in
            view.shakeOnError()
        })
    }
}

extension UIView {
    func shake(duration: CFTimeInterval) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation]
        shakeGroup.duration = duration
        layer.add(shakeGroup, forKey: "shakeIt")
    }
}
