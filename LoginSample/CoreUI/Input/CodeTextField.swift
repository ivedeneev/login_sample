//
//  CodeTextField.swift
//  LoginSample
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit

/// `UITextField` subclass to handle OTP code input. Each digit is underlined.
/// Aside from default properties you can customize code length, letter spacing,
///  underline dash height and placeholder color are configurable
/// **WARNING: using monospaced font is highly recommended**
final class CodeTextField: UITextField {
    
    /// Code length. Usually it 4-6 symbols. Default is 4
    var length: Int = 4
    
    /// Letter spacing between digits. Default is 24
    var letterSpacing: CGFloat = 24
    
    private var digitPadding: CGFloat {
        letterSpacing * 0.3
    }
    
    /// Height of underline dash
    var dashHeight: CGFloat = 3
    
    /// Used for placeholder and bottom dashes. Default is `UIColor.gray`
    var placeholderColor: UIColor = UIColor.gray
    
    /// Used for background rects under digits. Default is `UIColor(white: 0.9, alpha: 1)`
    var digitsBackgroundColor: UIColor = UIColor(white: 0.9, alpha: 1)
    
    /// Type of highlighting every digit. Available styles: dash, rounded rect or none. If dash or rect selected using monospaced font is highly recommended
    var highlightStyle: HighlightStyle = .none
    
    override var font: UIFont? {
        didSet {
            symbolWidth = _oneSymbolWidth()
            invalidateIntrinsicContentSize()
        }
    }
    
    private var _placeholder: String {
        String(repeating: "0", count: length)
    }
    
    private var symbolWidth: CGFloat!
    private var oldText = ""
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(placeholderColor.cgColor)
        context.setFillColor(digitsBackgroundColor.cgColor)
        
        switch highlightStyle {
        case .dash:
            context.setLineWidth(dashHeight)
            context.move(to: CGPoint(x: 0, y: bounds.height))
            context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
            context.setLineDash(phase: 0, lengths: [symbolWidth - letterSpacing, letterSpacing])
            context.strokePath()
        case .rect:
            let width: CGFloat = symbolWidth - letterSpacing + digitPadding * 2
            for i in 0..<length {
                let x = max(CGFloat(i) * (symbolWidth), 0)
                let rect = CGRect(x: x, y: 0, width: width, height: rect.height)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: 4).cgPath
                context.addPath(path)
            }
            
            context.fillPath()
        default:
            break
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(
            origin: textOrigin(),
            size: CGSize(width: bounds.width + letterSpacing + symbolWidth, height: bounds.height)
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(
            origin: textOrigin(),
            size: CGSize(width: bounds.width + letterSpacing, height: bounds.height)
        )
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(
            origin: textOrigin(),
            size: CGSize(width: bounds.width + letterSpacing, height: bounds.height)
        )
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
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
        
        switch highlightStyle {
        case .rect:
            size.width += digitPadding * 2
            size.height += digitPadding
        default:
            break
        }
        
        return size
    }
    
    private func _oneSymbolWidth() -> CGFloat {
        let attrstr = NSAttributedString(
            string: "0",
            attributes: [
                .font : font!,
                .kern: letterSpacing
            ])
                
        let size = attrstr.boundingRect(
            with: CGSize(width: 500, height: 500),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        ).size
        
        return size.width
    }
    
    private func textOrigin() -> CGPoint {
        let x: CGFloat = highlightStyle == .rect ? digitPadding : 0
        return CGPoint(x: x, y: 0)
    }
    
    @objc private func didChangeEditing() {
        guard let text = text, text.count > length else { oldText = self.text!; return }
        self.text = text.replacingOccurrences(of: oldText, with: "")
    }
}

extension CodeTextField {
    /// Type of highlighting every digit. Available styles: dash, rounded rect or none. If dash or rect selected using monospaced font is highly recommended
    enum HighlightStyle {
        
        /// no additinal graphics
        case none
        
        /// Each digit is underlined with dash
        case dash
        
        /// Each digit has rounded rectangle under it
        case rect
    }
}
