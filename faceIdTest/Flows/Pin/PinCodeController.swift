//
//  PinCodeController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 13.02.2021.
//

import UIKit
import RxSwift
import RxRelay
import LocalAuthentication
import RxCocoa

enum PinCodeType {
    case create
    case confirm
}

final class PinCodeController: BaseViewController {
    
    var viewModel: PinCodeViewModelProtocol!
    
    lazy var keyboardDigits: [PinPadItem] = {
        [1,2,3,4,5,6,7,8,9,0].map(PinPadItem.itemWithDigit)
    }()
    
    lazy var deleteButton = UIButton()
    lazy var faceIdButton = UIButton()
    lazy var forgotPasswordButton = UIButton()
    lazy var stack = UIStackView()
    lazy var titleLabel = UILabel()
    
    private lazy var codeField = DotsField()
    private let codeRelay = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    private func setup() {
        setupPinPad()
        setupDots()
    }
    
    private func setupDots() {
        view.addSubview(codeField)
        codeField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            codeField.bottomAnchor.constraint(greaterThanOrEqualTo: stack.topAnchor, constant: -40),
            codeField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupPinPad() {
        let line1 = UIStackView()
        line1.addArrangedSubview(keyboardDigits[0])
        line1.addArrangedSubview(keyboardDigits[1])
        line1.addArrangedSubview(keyboardDigits[2])
        line1.spacing = 8
        line1.distribution = .equalCentering
        
        let line2 = UIStackView()
        line2.addArrangedSubview(keyboardDigits[3])
        line2.addArrangedSubview(keyboardDigits[4])
        line2.addArrangedSubview(keyboardDigits[5])
        line2.spacing = 8
        line2.distribution = .equalCentering
        
        let line3 = UIStackView()
        line3.addArrangedSubview(keyboardDigits[6])
        line3.addArrangedSubview(keyboardDigits[7])
        line3.addArrangedSubview(keyboardDigits[8])
        line3.spacing = 8
        line3.distribution = .equalCentering
        
//        let line4 = UIStackView()
//        let dummyItem = PinPadItem()
//        dummyItem.backgroundColor = .clear
//        line4.addArrangedSubview(dummyItem)
//        line4.addArrangedSubview(keyboardDigits[9])
//        line4.addArrangedSubview(deleteButton)
//
//        line4.spacing = 8
//        line4.distribution = .equalCentering
        
        let vericalSpacing: CGFloat = 12
        
        stack.spacing = vericalSpacing
        stack.axis = .vertical
        
        stack.addArrangedSubview(line1)
        stack.addArrangedSubview(line2)
        stack.addArrangedSubview(line3)
//        stack.addArrangedSubview(line4)
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let zeroButton = keyboardDigits[9]
        view.addSubview(forgotPasswordButton)
        view.addSubview(zeroButton)
        view.addSubview(deleteButton)
        view.addSubview(faceIdButton)
        
        zeroButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        faceIdButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        forgotPasswordButton.setTitle("Забыли\nпароль?", for: .normal)
        forgotPasswordButton.setTitleColor(Color.text(), for: .normal)
        forgotPasswordButton.titleLabel?.numberOfLines = 0
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        forgotPasswordButton.titleLabel?.textAlignment = .center
        
        let buttonWidth: CGFloat = CGFloat(pinPadButtonSize)
        
        NSLayoutConstraint.activate([
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            
            zeroButton.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            zeroButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: vericalSpacing),
            
            deleteButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: zeroButton.centerYAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: buttonWidth),
            deleteButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            forgotPasswordButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            forgotPasswordButton.centerYAnchor.constraint(equalTo: zeroButton.centerYAnchor),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: buttonWidth),
            forgotPasswordButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            faceIdButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            faceIdButton.centerYAnchor.constraint(equalTo: zeroButton.centerYAnchor),
            faceIdButton.heightAnchor.constraint(equalToConstant: buttonWidth),
            faceIdButton.widthAnchor.constraint(equalToConstant: buttonWidth),
        ])
        
        deleteButton.backgroundColor = .clear
        deleteButton.setImage(UIImage(named: "keypad_delete"), for: .normal)
        deleteButton.tintColor = Color.green()
        
        faceIdButton.backgroundColor = .clear
        faceIdButton.setImage(UIImage(named: "faceId"), for: .normal)
        faceIdButton.tintColor = Color.green()
    }
    
    private func bind() {
        let digitSignals = keyboardDigits.map {
            $0.rx.controlEvent(.touchUpInside)
                .mapTo($0.digit)
                .compactMap { $0 }
                .map(String.init)
        }
        
        // поток ввода цифр
        let digitTapObservable = Observable.merge(digitSignals).withLatestFrom(codeRelay) { (digit, code) -> String in
            code.count < 4 ? code.appending(digit) : code
        }
        
        // поток нажатий на нижнюю правую кнопку
        let rightButtonTap = deleteButton.rx.tap.share().map { [unowned self] in self.codeRelay.value }
        
        // если заполнен хотя бы 1 символ - кнопка работает как delete;
        // если еще ничего не заполнено - даем возможность воспользоваться FaceID, если он разрешен
        let deleteTap = rightButtonTap.filter { !$0.isEmpty }
        
        // удаление последней цифры
        let deleteObservable = deleteTap.map { code in String(code.dropLast()) }
        
        // результирующий поток с кодом
        Observable.merge(digitTapObservable, deleteObservable, viewModel.incorrectCode.map { "" })
            .observe(on: MainScheduler.asyncInstance) // рекомендация от RxSwift для избежания циклического биндинга
            .bind(to: codeRelay)
            .disposed(by: disposeBag)
        
        // икнока для правой нижней кнопки (FaceID или удаление последнего символа)
        codeRelay
            .map { $0.isEmpty }
            .bind(to: deleteButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        codeRelay
            .map { [unowned self] code -> Bool in
                return !(code.isEmpty && self.viewModel.config.isBiometricsAvailable)
            }
            .bind(to: faceIdButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // заполнить точки
        codeRelay
            .map { $0.count }
            .filter { $0 > 0 } // для того, чтобы точки сразу не стирались при ошибке
            .bind(to: codeField.rx.numberOfFilledDots)
            .disposed(by: disposeBag)
        
        // "автоматом" заполнить точки, если сработала авторизация по FaceID
        let faceIdIsOn = true
        let viewDidAppearObservable = rx.sentMessage(#selector(viewDidAppear(_:)))
            .take(1)
            .filter { _ in faceIdIsOn }
            .mapTo(())
            .share()
        
        let evaluatedBiometrics = faceIdButton.rx.tap.asObservable()
            .merge(with: viewDidAppearObservable)
            .flatMapLatest { [unowned self] in
                self.evaluateBiometrics()
            }.share()
            
        evaluatedBiometrics
            .debug()
            .map { _ in
                4
            }
            .bind(to: codeField.rx.numberOfFilledDots)
            .disposed(by: disposeBag)
        
        // визуально обработать некорректно введенный код
        viewModel.incorrectCode
            .bind(to: codeField.rx.error)
            .disposed(by: disposeBag)
        
        codeRelay
            .bind(to: viewModel.code)
            .disposed(by: disposeBag)
        
        evaluatedBiometrics.bind(to: viewModel.evaluateBiometrics).disposed(by: disposeBag)
        forgotPasswordButton.rx.tap.bind(to: viewModel.forgotPassword).disposed(by: disposeBag)
        
        forgotPasswordButton.isHidden = !viewModel.config.showForgotPassword
        faceIdButton.isHidden = !viewModel.config.isBiometricsAvailable
    }
    
    func evaluateBiometrics() -> Observable<Void> {
        let context = LAContext()
        var error: NSError?
        
        return Observable.create { obs in
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return Disposables.create() }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "pls") { (success, authError) in
                if success {
                    obs.onNext(())
                    obs.onCompleted()
                    return
                }
            }
            
            return Disposables.create()
        }
    }
}
