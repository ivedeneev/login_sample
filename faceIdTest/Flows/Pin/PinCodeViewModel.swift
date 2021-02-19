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
    var needToRepeatCode: Observable<Void> { get }
    
    /// Доступна ли биометрическая авторизация ()
    var config: PinCodeConfig { get }
    
    /// Нажата кнопка "забыли пароль"
    var forgotPassword: AnyObserver<Void> { get }
    var didForgotPassword: Observable<Void> { get }
}

struct PinCodeConfig {
    let needsRepeat: Bool
    let showForgotPassword: Bool
    let isBiometricsAvailable: Bool
}

final class PinCodeViewModel: PinCodeViewModelProtocol {
    var code: AnyObserver<String>
    
    var didAuthenticate: Observable<Void>
    
    var evaluateBiometrics: AnyObserver<Void>
    
    var incorrectCode: Observable<Void>
    
    var needToRepeatCode: Observable<Void>
    
    var config: PinCodeConfig
    
    var forgotPassword: AnyObserver<Void>
    
    var didForgotPassword: Observable<Void>
    
    private let disposeBag = DisposeBag()
    
    init(config: PinCodeConfig) {
        self.config = config
        
        let _codeSubject = PublishSubject<String>()
        code = _codeSubject.asObserver()
        
        let maybeCorrectCode = _codeSubject.asObservable().filter { $0.count == 4 }.map {
            $0 == "5555"
        }.share()
        
        let correctCode = maybeCorrectCode.compactMap { $0 ? () : nil }
        incorrectCode = maybeCorrectCode.compactMap { !$0 ? () : nil }
        
        let _biometrics = PublishSubject<Void>()
        evaluateBiometrics = _biometrics.asObserver()
        
        didAuthenticate = correctCode
            .merge(with: _biometrics.asObservable())
        
        let _forgotPassword = PublishSubject<Void>()
        forgotPassword = _forgotPassword.asObserver()
        didForgotPassword = _forgotPassword.asObservable()
        
        needToRepeatCode = correctCode.take(1).filter { _ in config.needsRepeat }
    }
}
