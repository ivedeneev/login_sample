//
//  PersonalDataViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 03.02.2021.
//

import UIKit
import RxSwift

final class PersonalDataViewController: BaseViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 84),
        ])
        
        let helloLabel = UILabel()
        helloLabel.text = "Почти все!"
        helloLabel.font = Font.title
        helloLabel.textAlignment = .center
        helloLabel.textColor = Color.text()
        helloLabel.numberOfLines = 2
        
        stackView.addArrangedSubview(helloLabel)
        
        let enterPhoneLabel = UILabel()
        enterPhoneLabel.text = "Как к вам обращаться?"
        enterPhoneLabel.font = Font.title2
        enterPhoneLabel.textAlignment = .center
        enterPhoneLabel.textColor = Color.text()
        stackView.addArrangedSubview(enterPhoneLabel)
        
        let phoneTextField = PhoneTextField()
//        phoneTextField.attributedPlaceholder = phoneTextField.phoneMask
        phoneTextField.placeholder = "+7 (999) 999-99-99"
        phoneTextField.font = .monospacedDigitSystemFont(ofSize: 30, weight: .light)
        phoneTextField.isUserInteractionEnabled = false
        stackView.addArrangedSubview(phoneTextField)
    }
}

final class PersonalDataCoordinator: BaseCoordinator<AuthResult> {
    
    init(nc: UIViewController?) {
        super.init()
        rootViewController = nc
    }
    
    override func start() -> Observable<AuthResult> {
        let vc = PersonalDataViewController()
        (rootViewController as? UINavigationController)?.setViewControllers([vc], animated: true)
        return .empty()
    }
}
