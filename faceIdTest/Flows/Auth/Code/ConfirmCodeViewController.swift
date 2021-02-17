//
//  SMSViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class ConfirmCodeViewController: BaseViewController {
    
    var viewModel: ConfirmCodeViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    let codeTextField = CodeTextField()
    
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
        helloLabel.text = "Код подтверждения:"
        helloLabel.font = Font.title
        helloLabel.textAlignment = .center
        helloLabel.textColor = Color.text()
        helloLabel.numberOfLines = 2
        
        stackView.addArrangedSubview(helloLabel)
        
        
//        codeTextField.placeholder = "____"
        codeTextField.showDashes = true
        codeTextField.font = .monospacedDigitSystemFont(ofSize: 30, weight: .light)
        stackView.addArrangedSubview(codeTextField)
//        codeTextField.backgroundColor = UIColor.blue.withAlphaComponent(0.25)
        stackView.setCustomSpacing(20, after: codeTextField)
        
        let errorLabel = UILabel()
        errorLabel.numberOfLines = 2
        errorLabel.textColor = Color.red()
        stackView.addArrangedSubview(errorLabel)
        
        let loader = UIActivityIndicatorView()
        stackView.addArrangedSubview(loader)
        
        let timerLabel = UILabel()
        timerLabel.numberOfLines = 2
        stackView.addArrangedSubview(timerLabel)
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitleColor(UIColor.white, for: .normal)
        retryButton.setTitle("отправить заново".uppercased(), for: .normal)
        retryButton.isHidden = true
        retryButton.backgroundColor = Color.accent()
        retryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        retryButton.titleEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        stackView.addArrangedSubview(retryButton)
        
        codeTextField.rx
            .controlEvent(.editingChanged)
            .map { [unowned codeTextField] in
                return codeTextField.text ?? ""
            }
            .bind(to: viewModel.code)
            .disposed(by: disposeBag)
        
        retryButton.rx.tap
            .bind(to: viewModel.getNewCode)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .asDriver()
            .drive(loader.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.didRequestNewCode
            .mapTo("")
            .asDriver(onErrorJustReturn: "")
            .drive(codeTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.errors
            .asDriver()
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.didRequestNewCode
            .mapTo(Optional<String>.none)
            .asDriver(onErrorJustReturn: Optional<String>.none)
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)
        
        let newCodeDriver = viewModel.newCodeTimer.asDriver()
        
        newCodeDriver
            .map { (sec) -> String? in
                guard let s = sec else { return nil }
                return "Не пришел код? Повторый запрос возможен через  \(s) сек"
            }
            .drive(timerLabel.rx.text)
            .disposed(by: disposeBag)
        
        newCodeDriver
            .map { $0 != nil }
            .skip(1)
            .drive(retryButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        codeTextField.becomeFirstResponder()
    }
}
