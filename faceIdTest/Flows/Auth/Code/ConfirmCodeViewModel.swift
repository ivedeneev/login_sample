//
//  ConfirmCodeViewModel.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxCocoa

enum AuthResult {
    case success
    case needPersonalData
}

protocol ConfirmCodeViewModelProtocol {
    
    /// Введенный пользователем код для подтверждения
    var code: AnyObserver<String> { get }
    
    /// Пользователь нажал на "отправить повторно"
    var getNewCode: AnyObserver<Void> { get }
    
    /// Результат подтверждения кода
    var result: Observable<AuthResult> { get }
    var isLoading: BehaviorRelay<Bool> { get }
    
    /// Ошибки из всех запросов на этом экране
    var errors: BehaviorRelay<String?> { get }
    
    /// Таймер отправки нового кода
    var newCodeTimer: BehaviorRelay<Int?> { get }
    
    /// Запросили новый код при нажатии на "отправить заново"
    var didRequestNewCode: Observable<Void> { get }
}

final class ConfirmCodeViewModel: ConfirmCodeViewModelProtocol {
    
    var code: AnyObserver<String>
    var getNewCode: AnyObserver<Void>
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errors = BehaviorRelay<String?>(value: nil)
    var newCodeTimer = BehaviorRelay<Int?>(value: nil)
    var result: Observable<AuthResult>
    var didRequestNewCode: Observable<Void>
    
    private let disposeBag = DisposeBag()
    
    init(token: String, phone: String, authService: AuthServiceProtocol = AuthService()) {
        let _codeSubject = PublishSubject<String>()
        code = _codeSubject.asObserver()
        
        let _getCode = PublishSubject<Void>()
        getNewCode = _getCode.asObserver()
        
        let codeObservable = _codeSubject.asObservable()
        
        let validCodeObservable = codeObservable.filter { $0.count == 4 }
        
        // запрос нового кода
        let fetchNewCode = _getCode.asObservable()
            .flatMap {
                authService.loginByPhone(phone: phone).materialize()
            }.share()
        
        didRequestNewCode = fetchNewCode.elements().mapTo(())
        
        let codeEvents = validCodeObservable
            .flatMap { (code) in
                authService.confirmCode(code: code, token: token).materialize()
            }.share()
        
        result = codeEvents.elements()
        
        let codeTimer = 3
        validCodeObservable.mapTo(()).merge(with: didRequestNewCode)
            .take(until: fetchNewCode)
            .flatMap { _ -> Observable<Int?> in
                Observable.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .take(codeTimer + 1)
                    .map { (tick: Int) -> Int? in
                        let res = codeTimer - tick - 1
                        return res < 0 ? nil : res
                    }
            }
            .bind(to: newCodeTimer)
            .disposed(by: disposeBag)
        
        codeEvents.mapTo(false).bind(to: isLoading).disposed(by: disposeBag)
        validCodeObservable.mapTo(true).bind(to: isLoading).disposed(by: disposeBag)
        
        _getCode.asObservable().mapTo(true).bind(to: isLoading).disposed(by: disposeBag)
        fetchNewCode.mapTo(false).bind(to: isLoading).disposed(by: disposeBag)
        
        codeEvents.errors()
            .compactMap { ($0 as? AuthErrorType)?.localizedDescription }
            .bind(to: errors)
            .disposed(by: disposeBag)
        
        codeObservable
            .mapTo(Optional<String>.none)
            .bind(to: errors)
            .disposed(by: disposeBag)
    }
}
