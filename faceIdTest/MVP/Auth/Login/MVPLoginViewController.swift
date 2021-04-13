//
//  MVPLoginViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 31.03.2021.
//

import UIKit

final class MVPLoginViewController: UIViewController, LoginView {
    
    lazy var phoneTextField = PhoneTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        phoneTextField.becomeFirstResponder()
    }
    
    private func setup() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
//        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 4
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
        ])
        
//        let helloLabel = UILabel()
//        helloLabel.text = "Введите номер телефона"
//        helloLabel.font = Font.title
////        helloLabel.textAlignment = .center
//        helloLabel.textColor = Color.text()
//        helloLabel.numberOfLines = 2
//
//        stackView.addArrangedSubview(helloLabel)
        
        let enterPhoneLabel = UILabel()
        enterPhoneLabel.text = "Мы отправим на него СМС-код"
        enterPhoneLabel.font = Font.title2
//        enterPhoneLabel.textAlignment = .center
        enterPhoneLabel.textColor = Color.text()
        
        
//        phoneTextField.attributedPlaceholder = phoneTextField.phoneMask
        phoneTextField.placeholder = "Ваш номер телефона"
        phoneTextField.font = .monospacedDigitSystemFont(ofSize: 30, weight: .semibold)
        stackView.addArrangedSubview(phoneTextField)
        stackView.addArrangedSubview(enterPhoneLabel)
        
        let termsTextView = UITextView()
        termsTextView.isEditable = false
        termsTextView.isScrollEnabled = false
        termsTextView.linkTextAttributes = [.foregroundColor: Color.lightGreen()]
        termsTextView.backgroundColor = Color.background()
        
        let termsAttrString = NSMutableAttributedString(
            string: "Нажимая продолжить, вы соглашаетесь с условиями ",
            attributes: [
                .font : Font.caption,
                .foregroundColor: Color.lightGrayText()
            ]
        )
        
        let link = NSMutableAttributedString(
            string: "лицензионного соглашения",
            attributes: [
                .font : Font.captionBold,
                .foregroundColor: Color.lightGreen(),
                .link : URL(string: "www.agima.ru")!
            ]
        )
        
        termsAttrString.append(link)
        
        termsTextView.attributedText = termsAttrString
        
        stackView.addArrangedSubview(termsTextView)
        
//        stackView.setCustomSpacing(0, after: helloLabel)
//        stackView.setCustomSpacing(20, after: phoneTextField)
        
        let loader = UIActivityIndicatorView()
        stackView.addArrangedSubview(loader)
        
        let errorButton = UIButton(type: .system)
        errorButton.setTitleColor(Color.red(), for: .normal)
        
        stackView.addArrangedSubview(errorButton)
    
    }
    
    func obtainError(_ error: Error) {
        
    }
    
    func obtainLoading(_ isLoading: Bool) {
        
    }
}

final class LoginPresenterImpl: LoginPresenter {
    
    weak var view: LoginView?
    
    init(authService: AuthService) {
        
    }
    
    func obtainPhone(_ phone: String) {
        
    }
    
    func resendPhone() {
        
    }
    
    func showTerms() {
        
    }
}

protocol LoginView: AnyObject {
    func obtainError(_ error: Error)
    func obtainLoading(_ isLoading: Bool)
}

protocol LoginPresenter {
    var view: LoginView? { get set }
    
    /// Input
    func obtainPhone(_ phone: String)
    func resendPhone()
    func showTerms()
    
    /// Output
}
