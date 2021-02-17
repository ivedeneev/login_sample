//
//  BasePopover.swift
//  Megadisk
//
//  Created by Igor Vedeneev on 9/13/19.
//  Copyright © 2019 AGIMA. All rights reserved.
//

import UIKit
import RxSwift

protocol PopoverDelegate: class {
    func didAnimate(popover: BasePopover, fractionCompleted: CGFloat)
    func didBeginAnimation(popover: BasePopover)
    func didEndAnimation(popover: BasePopover, fractionCompleted: CGFloat)
}

class BasePopover: BaseViewController {
    private lazy var lastHeight: CGFloat = minHeight
    
    // properties to override
    var minHeight: CGFloat { return 0 }
    var maxHeight: CGFloat { 250 }
    var threshold: CGFloat  { return 20 }
    
    weak var delegate: PopoverDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        addPinView()
        setupView()
        setupKeyboardListener()
    }
    
    private func setupView() {
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = Color.background()
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: view.bounds.width, height: 12),
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 16, height: 16)
        ).cgPath
        
        
        let tapView = UIView()
        view.addSubview(tapView)
        
        tapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tapView.topAnchor.constraint(equalTo: view.topAnchor),
            tapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let bottomView = UIView()
        bottomView.backgroundColor = Color.background()
        view.addSubview(bottomView)
        
        let panGr = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGr)
    }
    
    private func setupKeyboardListener() {
//        NotificationCenter.default.reactive.keyboardChange.take(duringLifetimeOf: self).observeValues { [weak self] context in
//            guard let `self` = self else { return }
//            let isUp = context.endFrame.minY < context.beginFrame.minY
//            let bottomSafeArea = self.view.superview!.safeAreaInsets.bottom
//            let offset: CGFloat = isUp ? -context.endFrame.height + bottomSafeArea : bottomSafeArea
//            self.view.snp.updateConstraints { make in
//                make.bottom.equalTo(self.view.superview!.safeAreaLayoutGuide.snp.bottom).offset(offset)
//            }
//
//            UIView.animate(withDuration: context.animationDuration,
//               delay: 0,
//               options: [UIView.AnimationOptions(rawValue: UInt(context.animationCurve.rawValue))],
//               animations: {
//                    self.animateKeyboard(context: context)
//                    self.view.superview?.layoutIfNeeded()
//               }, completion: nil)
//        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: .main) { (note) in
            
            guard
                let rect = note.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect,
                let duration = note.userInfo?["UIKeyboardAnimationCurveUserInfoKey"] as? TimeInterval,
                let curve = note.userInfo?["UIKeyboardAnimationCurveUserInfoKey"] as? UInt
                else { return }
            
//            let bottomSafeArea = self.view.superview!.safeAreaInsets.bottom
//            let offset: CGFloat = -rect.height + bottomSafeArea
//            self.view.snp.updateConstraints { make in
//                make.bottom.equalTo(self.view.superview!.safeAreaLayoutGuide.snp.bottom).offset(offset)
//            }
            
            self.view.constraints.first(where: { $0.firstAttribute == .height })?.constant = self.maxHeight

            UIView.animate(withDuration: duration,
               delay: 0,
               options: [UIView.AnimationOptions(rawValue: curve)],
               animations: {
//                    self.animateKeyboard(context: context)
                    self.view.superview?.layoutIfNeeded()
               }, completion: nil)
        }
    }
    
    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        switch gr.state {
        case .began:
            lastHeight = view.frame.height
            delegate?.didBeginAnimation(popover: self)
        case .ended:
            if abs(view.frame.height - maxHeight) < threshold || view.frame.height > maxHeight {
                lastHeight = maxHeight
            } else {
                lastHeight = minHeight
                
                if minHeight == 0 {
                    dismiss(animated: true, completion: nil)
                }
            }
            
            if lastHeight == minHeight {
                view.endEditing(true)
            }
            
            
            
            if lastHeight == minHeight {
                view.constraints.first(where: { $0.firstAttribute == .bottom })?.constant = 0
            }
            
            view.constraints.first(where: { $0.firstAttribute == .height })?.constant = lastHeight
            
            layoutIfNeededAnimated(duration: 0.4, fractionCompleted: lastHeight == minHeight ? 0 : 1)
        case .changed:
            
            var expectedHeight = lastHeight -  gr.translation(in: view).y
            if expectedHeight > maxHeight {
                expectedHeight = maxHeight + (expectedHeight - maxHeight) * (maxHeight / expectedHeight) * 0.7
            }
            
            view.constraints.first(where: { $0.firstAttribute == .height })?.constant = expectedHeight
            
            var distance = abs(view.frame.height) / (maxHeight - minHeight)
            distance = (expectedHeight - minHeight) / (maxHeight - minHeight)
            let fraction =  min(max(distance, 0), 1)
            delegate?.didAnimate(popover: self, fractionCompleted: fraction)
            updateUI(fraction: fraction)
            
            view.superview?.layoutIfNeeded()
        default:
            break
        }
    }
    
    @objc func toggleInfoPopup() {
        
        view.endEditing(true)
        let height: CGFloat = view.frame.height == minHeight || view.frame.maxY < view.frame.maxY - view.safeAreaInsets.bottom  ? maxHeight : minHeight
        let shouldAnimateToBottom = view.frame.height == maxHeight
        
        if shouldAnimateToBottom {
            dismiss(animated: true, completion: nil)
        }
        
//        view.snp.updateConstraints { (make) in
//            make.height.equalTo(height)
//            if shouldAnimateToBottom {
//                make.bottom.equalToSuperview()
//            }
//        }
        
        view.constraints.first(where: { $0.firstAttribute == .height })?.constant = height
        
        if shouldAnimateToBottom {
            view.constraints.first(where: { $0.firstAttribute == .bottom })?.constant = 0
        }
        
        layoutIfNeededAnimated(duration: 0.6, fractionCompleted: height == minHeight ? 0 : 1)
    }
    
    func toggle() {
        toggleInfoPopup()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        handleTouchesEnded()
    }
    
    func layoutIfNeededAnimated(duration: TimeInterval, fractionCompleted: CGFloat) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [.allowAnimatedContent], animations: {
            self.view.superview?.layoutIfNeeded()
            self.updateUI(fraction: fractionCompleted)
        }, completion: { _ in
            self.delegate?.didEndAnimation(popover: self, fractionCompleted: fractionCompleted)
        })
    }
    
    
    func updateUI(fraction: CGFloat) {
    }
    
//    func animateKeyboard(context: ReactiveCocoa.KeyboardChangeContext) {
//
//    }
    
    func handleTouchesEnded() {
//        UIApplication.shared.delegate!.window!!.endEditing(true)
    }
}
