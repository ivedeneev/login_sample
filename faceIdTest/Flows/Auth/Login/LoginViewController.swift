//
//  LoginViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxSwiftExt

final class LoginViewController: BaseViewController {
    
    var viewModel: LoginViewModelProtocol!
    private let disposeBag = DisposeBag()
    
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
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 4
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
        ])
        
        let enterPhoneLabel = UILabel()
        enterPhoneLabel.text = "Мы отправим на него СМС-код"
        enterPhoneLabel.font = Font.title2
        enterPhoneLabel.textColor = Color.text()
        
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
        
        let loader = UIActivityIndicatorView()
        stackView.addArrangedSubview(loader)
        
        let errorButton = UIButton(type: .system)
        errorButton.setTitleColor(Color.red(), for: .normal)
        
        stackView.addArrangedSubview(errorButton)
        
        phoneTextField.rx
            .formattedPhone
            .bind(to: viewModel.phoneNumber)
            .disposed(by: disposeBag)
        
        errorButton.rx.tap
            .bind(to: viewModel.resendPhone)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(loader.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.errors
            .asDriver()
            .drive(errorButton.rx.title())
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .not()
            .drive(phoneTextField.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
