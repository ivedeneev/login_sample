//
//  PhoneTextField.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 03.02.2021.
//

import UIKit

protocol PhoneTextFieldFormattingDelegate: class {
    func formatPhoneNumber(for tf: PhoneTextField) -> String
}

final class PhoneTextField: UITextField {
    
    weak var formattingDelegate: PhoneTextFieldFormattingDelegate?
    
    /// Phone format string were X is digit placeholder. Default is `+X (XXX) XXX-XX-XX`
    var phoneMask: String = "+X (XXX) XXX-XX-XX"
    
    override var intrinsicContentSize: CGSize {
        let font_ = font ?? UIFont.systemFont(ofSize: 17)
        let height = font_.lineHeight
        let width = (phoneMask.appending(" ") as NSString).boundingRect(
            with: CGSize(width: 500, height: 100),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            attributes: [.font : font_],
            context: nil).width
        
        return CGSize(width: width, height: height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addTarget(self, action: #selector(didChangeEditing), for: .editingChanged)
        textContentType = .telephoneNumber
        keyboardType = .phonePad
    }
    
    @objc private func didChangeEditing() {
        if let delegate = formattingDelegate {
            text = delegate.formatPhoneNumber(for: self)
            return
        }
        
        guard var t = text?.trimmingCharacters(in: .whitespacesAndNewlines), t != "+" else { return }
        
        switch t.first {
        case "8":
            t = "+7" + t.dropFirst()
        case "9":
            t = "+7" + t
        default:
            break
        }
        
        if t.count > 1, t.first != "+" || String(Array(t)[1]) != "7" && t.first == "+" {
            t.insert(contentsOf: "+7", at: .init(utf16Offset: 0, in: t))
        }
        
        text = t.formattedNumber(mask: phoneMask)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        guard let p = placeholder else { return bounds }
        let placeholderWidth = p.boundingRect(
            with: CGSize(width: 500, height: 500),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            attributes: [.font: font],
            context: nil
        ).size.width.rounded(.up)
        
        return CGRect(x: (bounds.width - placeholderWidth) / 2, y: 0, width: placeholderWidth, height: bounds.height)
    }
}

extension String {
    func formattedNumber(mask: String) -> String {
        let rawPhone = digitsOnly()

        var result = ""
        var index = rawPhone.startIndex
        for ch in mask where index < rawPhone.endIndex {
            if ch == "X" {
                result.append(rawPhone[index])
                index = rawPhone.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func digitsOnly() -> String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }

    var isValidPhone: Bool {
        return digitsOnly().count == 11
    }

    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
}

#if canImport(RxSwift)
import RxSwift

extension Reactive where Base: PhoneTextField {
    var formattedPhone: Observable<String> {
        controlEvent(.editingChanged)
            .map { [weak base] in
                return base?.text ?? ""
            }
    }
}
#endif
