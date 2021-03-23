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

let codeTimerLimit = 3

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
    var didAuthorize: Observable<AuthResult> { get }
    
    /// Один индикатор на все запросы на этом экране
    var isLoading: BehaviorRelay<Bool> { get }
    
    /// Ошибки из всех запросов на этом экране
    var errors: Observable<String> { get }
    
    /// Таймер отправки нового кода
    var newCodeTimer: BehaviorRelay<Int> { get }
    
    /// Запросили новый код при нажатии на "отправить заново"
    var didRequestNewCode: Observable<Void> { get }
}

final class ConfirmCodeViewModel: ConfirmCodeViewModelProtocol {
    
    var code: AnyObserver<String>
    var getNewCode: AnyObserver<Void>
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errors: Observable<String>
    var newCodeTimer = BehaviorRelay<Int>(value: codeTimerLimit)
    var didAuthorize: Observable<AuthResult>
    var didRequestNewCode: Observable<Void>
    
    private let disposeBag = DisposeBag()
    
    init(token: String,
         phone: String,
         codeLength: Int = 4,
         
         authService: AuthServiceProtocol = AuthService())
    {
        let _codeSubject = PublishSubject<String>()
        code = _codeSubject.asObserver()
        
        let _getCode = PublishSubject<Void>()
        getNewCode = _getCode.asObserver()
        
        let codeObservable = _codeSubject.asObservable()
        
        let validCodeObservable = codeObservable.filter { $0.count == codeLength }
        
        // запрос нового кода
        let fetchNewCode = _getCode.asObservable()
            .flatMap {
                authService.loginByPhone(phone: phone).materialize()
            }.share()
        
        didRequestNewCode = fetchNewCode.elements().mapToVoid()
        
        let codeEvents = validCodeObservable
            .flatMap { (code) in
                authService.confirmCode(code: code, token: token).materialize()
            }.share()
        
        didAuthorize = codeEvents.elements()
        
        Observable.merge(validCodeObservable.mapToVoid(), didRequestNewCode, .just(()))
            .flatMap { _ -> Observable<Int> in
                Observable.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .map { codeTimerLimit - $0 - 1 }
                    .take(while: { $0 >= 0 })
            }
            .bind(to: newCodeTimer)
            .disposed(by: disposeBag)
        
        codeEvents.mapTo(false).distinctUntilChanged().bind(to: isLoading).disposed(by: disposeBag)
        validCodeObservable.mapTo(true).distinctUntilChanged().bind(to: isLoading).disposed(by: disposeBag)
        
        _getCode.asObservable().mapTo(true).distinctUntilChanged().bind(to: isLoading).disposed(by: disposeBag)
        fetchNewCode.mapTo(false).distinctUntilChanged().bind(to: isLoading).disposed(by: disposeBag)
        
        errors = codeEvents.errors()
            .compactMap { ($0 as? AuthErrorType)?.localizedDescription }
    }
}

