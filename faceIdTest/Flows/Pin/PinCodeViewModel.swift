//
//  PinCodeViewModel.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 19.02.2021.
//

import Foundation
import RxSwift


protocol PinCodeViewModelProtocol {
    /// Пользователь ввел код
    var code: AnyObserver<String> { get }
    
    /// Пользователь успешно авторизовался
    var didAuthenticate: Observable<Void> { get }
    
    /// Пользователь успешно авторизовался с помощью FaceID/TouchID
    var evaluateBiometrics: AnyObserver<Void> { get }
    
    /// Код не прошел проверку
    var incorrectCode: Observable<Void> { get }
    
    /// Требуется повторить ввод кода (для создания)
    var shouldConfirmCode: Observable<Void> { get }
    
    var pinType: PinCodeType { get }
    
    /// Нажата кнопка "забыли пароль"
    var forgotPassword: AnyObserver<Void> { get }
    var didForgotPassword: Observable<Void> { get }
}

enum PinCodeType {
    case create
    case confirm
    
    /// Требуется подтверждение кода
    var needsConfirmation: Bool {
        self == .create
    }
    
    var canForceLogout: Bool {
        self == .confirm
    }
    
    var canUseBiometrics: Bool {
        self == .confirm
    }
}

final class PinCodeViewModel: PinCodeViewModelProtocol {
    
    var code: AnyObserver<String>
    var didAuthenticate: Observable<Void>
    var evaluateBiometrics: AnyObserver<Void>
    var incorrectCode: Observable<Void>
    var shouldConfirmCode: Observable<Void>
    var pinType: PinCodeType
    var forgotPassword: AnyObserver<Void>
    var didForgotPassword: Observable<Void>
    
    private let disposeBag = DisposeBag()
    
    init(pinType: PinCodeType, prefs: Preferences = Preferences(), codeLength: Int = 4) {
        self.pinType = pinType
        
        let _codeSubject = PublishSubject<String>()
        code = _codeSubject.asObserver()
        
        let _code = _codeSubject.asObservable()
            .filter { $0.count == codeLength }
            .share()
        
        let _biometrics = PublishSubject<Void>()
        evaluateBiometrics = _biometrics.asObserver()
        
        if pinType.needsConfirmation {
            let firstCode = _code.take(1)
            shouldConfirmCode = _code.mapToVoid().take(1).share()
            let correctlyRepeatedCode = _code.skip(1).withLatestFrom(firstCode, resultSelector: { $0 == $1 }).share()
            incorrectCode = correctlyRepeatedCode.filter { !$0 }.mapToVoid()
            didAuthenticate = correctlyRepeatedCode.filter { $0 }.mapToVoid()
            
            correctlyRepeatedCode.withLatestFrom(_code)
                .bind(to: prefs.rx.keyPath(kp: \.pinCode))
                .disposed(by: disposeBag)
        } else {
            let maybeCorrectCode = _code
                .map { $0 == prefs.pinCode }
                .share()
            
            let correctCode = maybeCorrectCode.compactMap { $0 ? () : nil }
            incorrectCode = maybeCorrectCode.compactMap { !$0 ? () : nil }
            
            didAuthenticate = correctCode
                .merge(with: _biometrics.asObservable())
            
            shouldConfirmCode = .empty()
        }
        
        let _forgotPassword = PublishSubject<Void>()
        forgotPassword = _forgotPassword.asObserver()
        didForgotPassword = _forgotPassword.asObservable()
    }
}

extension Observable {
    /// Maps values to `Void`
    func mapToVoid() -> Observable<Void> {
        mapTo(())
    }
}
