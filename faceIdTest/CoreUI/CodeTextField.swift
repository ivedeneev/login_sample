//
//  CodeTextField.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit

/// `UITextField` subclass to handle OTP code input. Each digit is underlined.
/// Aside from default properties you can customize code length, letter spacing,
///  underline dash height and placeholder color are configurable
final class CodeTextField: UITextField {
    /// Code length. Usually it 4-6 symbols. Default is 4
    var length: Int = 4
    
    /// Letter spacing between digits
    var letterSpacing: CGFloat = 20
    
    /// Height of underline dash
    var dashHeight: CGFloat = 3
    
    /// Used for placeholder and bottom dashes. Default is `UIColor.gray`
    var placeholderColor: UIColor = UIColor.gray
    
    /// Draw dash under each digit. Default is `false`
    var showDashes: Bool = false
    
    override var font: UIFont? {
        didSet {
            symbolWidth = _oneSymbolWidth()
            invalidateIntrinsicContentSize()
        }
    }
    
//    override var placeholder: String? {
//        didSet {
//            guard let placeholder = placeholder else { return }
//            attributedPlaceholder = NSAttributedString(
//                string: placeholder,
//                attributes: [
//                    .font : font!,
//                    .kern: letterSpacing,
//                ])
//        }
//    }
    
    private var _placeholder: String {
//        String(repeating: "•", count: length)
        String(repeating: "0", count: length)
    }
    
    private var symbolWidth: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    private func setup() {
        addTarget(self, action: #selector(didChangeEditing), for: .editingChanged)
        defaultTextAttributes.updateValue(letterSpacing, forKey: .kern)
        tintColor = .clear
        keyboardType = .numberPad
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        }
    }
    
//    override func drawText(in rect: CGRect) {
//        let s = NSMutableParagraphStyle()
//        s.minimumLineHeight = font!.lineHeight
//        let attrstr = NSAttributedString(
//            string: _placeholder,
//            attributes: [
//                .font : font!,
//                .foregroundColor: placeholderColor,
//                .kern: letterSpacing
//            ])
//
//        attrstr.draw(in: textRect(forBounds: bounds))
//
//        super.drawText(in: rect)
//    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext(), showDashes else { return }
        
        context.setStrokeColor(placeholderColor.cgColor)
        context.setLineWidth(dashHeight)
        context.move(to: CGPoint(x: 0, y: bounds.height))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context.setLineDash(phase: 0, lengths: [symbolWidth - letterSpacing, letterSpacing])
        context.strokePath()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: bounds.width + letterSpacing, height: bounds.height)
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: bounds.width + letterSpacing, height: bounds.height)
        )
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: bounds.width + letterSpacing, height: bounds.height)
        )
    }
    
    override var intrinsicContentSize: CGSize {
        let attrstr = NSAttributedString(
            string: _placeholder,
            attributes: [
                .font : font!,
                .kern: letterSpacing
            ])
                
        var size = attrstr.boundingRect(
            with: CGSize(width: 500, height: 500),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        ).size
        size.width -= letterSpacing
        return size
    }
    
    func _oneSymbolWidth() -> CGFloat {
        let attrstr = NSAttributedString(
            string: "0",
            attributes: [
                .font : font!,
                .kern: letterSpacing
            ])
                
        let size = attrstr.boundingRect(with: CGSize(width: 500, height: 500),
                                        options: [.usesFontLeading, .usesLineFragmentOrigin],
                                        context: nil).size
        return size.width
    }
    
    @objc private func didChangeEditing() {
        guard let text = text else { return }
        if text.count > length {
            self.text = String(text.prefix(length))
        }
    }
}
