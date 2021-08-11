//
//  TextField.swift
//  jetfly
//
//  Created by Igor Vedeneev on 26/08/2018.
//  Copyright © 2018 Igor Vedeneev. All rights reserved.
//

import UIKit

class FloatingLabelTextField : UITextField {
    
    private var placeholderFont: UIFont! {
        didSet {
            placeholderLabel.font = placeholderFont
            invalidateIntrinsicContentSize()
        }
    }
    private let underlineLayer = CALayer()
    private var placeholderLabel = UILabel()
    var flotatingLabelTopPosition: CGFloat = 0
    var showUnderlineView = true
    
    override var placeholder: String? {
        didSet {
            guard placeholder != nil else { return }
            placeholderLabel.text = placeholder
            placeholderLabel.sizeToFit()
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderFont = font!
            placeholderLabel.sizeToFit()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let height = font!.lineHeight * 2.5
        return CGSize(width: 200, height: height)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    private func initialSetup() {
        layer.addSublayer(underlineLayer)
        underlineLayer.backgroundColor = UIColor.separator.cgColor
        borderStyle = .none
        backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        
        placeholderLabel.textColor = UIColor.secondaryLabel
        addSubview(placeholderLabel)
        clearButtonMode = .always
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(kg_textDidChange(notif:)),
            name: UITextField.textDidChangeNotification,
            object: nil
        )
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel.frame = CGRect(origin: .zero, size: .zero)
    }
    
    private func animatePlaceholderLabelOnTop() {
        UIView.animate(withDuration: 0.2) {
            self.setPlaceholderTopAttributes()
        }
    }
    
    private func animatePlaceholderLabelOnBottom() {
        UIView.animate(withDuration: 0.2) {
            self.setPlaceholderBottomAttributes()
        }
    }
    
    private func setPlaceholderTopAttributes() {
        placeholderLabel.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        placeholderLabel.frame.origin.x = 0
        let top: CGFloat = 0
        placeholderLabel.frame.origin.y = top
    }
    
    private func setPlaceholderBottomAttributes() {
        placeholderLabel.transform = .identity
        placeholderLabel.frame.origin.x = 0
        placeholderLabel.frame.origin.y = (bounds.height - placeholderLabel.font.lineHeight + padding.top) / 2
    }
    
    @objc private func kg_textDidChange(notif: Notification) {
        guard let textField = notif.object as? FloatingLabelTextField, textField == self else { return }
        
        if placeholderLabel.superview == nil {
            addSubview(placeholderLabel)
        }
        
        if let txt = text, !txt.isEmpty {
            if self.placeholderLabel.frame.origin.y != flotatingLabelTopPosition {
                animatePlaceholderLabelOnTop()
            }
        } else {
            animatePlaceholderLabelOnBottom()
        }
    }
    
    private var padding: UIEdgeInsets {
        UIEdgeInsets(top: font!.lineHeight / 2, left: 0, bottom: font!.lineHeight / 2, right: 0);
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        .zero
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()

        if (text ?? "").isEmpty {
            setPlaceholderBottomAttributes()
        } else {
            setPlaceholderTopAttributes()
        }
    }
}
