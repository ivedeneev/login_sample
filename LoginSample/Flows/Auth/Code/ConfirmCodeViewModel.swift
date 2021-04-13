//
//  ConfirmCodeViewModel.swift
//  LoginSample
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
    var didAuthorize: Driver<AuthResult> { get }
    
    /// Один индикатор на все запросы на этом экране
    var isLoading: Driver<Bool> { get }
    
    /// Ошибки из всех запросов на этом экране
    var errors: Driver<String> { get }
    
    /// Таймер отправки нового кода
    var newCodeTimer: Driver<Int> { get }
    
    /// Запросили новый код при нажатии на "отправить заново"
    var didRequestNewCode: Driver<Void> { get }
}

final class ConfirmCodeViewModel: ConfirmCodeViewModelProtocol {
    
    let code: AnyObserver<String>
    let getNewCode: AnyObserver<Void>
    
    let didAuthorize: Driver<AuthResult>
    
    let isLoading: Driver<Bool>
    let errors: Driver<String>
    
    let newCodeTimer: Driver<Int>
    let didRequestNewCode: Driver<Void>
    
    private let disposeBag = DisposeBag()
    
    init(token: String,
         phone: String,
         codeLength: Int = 4,
         resendCodeTimeout: Int = 3,
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
            .flatMapLatest {
                authService.loginByPhone(phone: phone).materialize()
            }
            .share()
        
        let _newCode = fetchNewCode.elements().mapTo(Void())
        didRequestNewCode = _newCode.asDriver(onErrorJustReturn: ())
        
        let codeEvents = validCodeObservable
            .flatMapLatest { (code) in
                authService.confirmCode(code: code, token: token).materialize()
            }
            .share()
        
        didAuthorize = codeEvents.elements().asDriver(onErrorJustReturn: .needPersonalData)
        
        let _timer = BehaviorRelay<Int>(value: codeTimerLimit)
        newCodeTimer = _timer.asDriver()
        
        Observable.merge(validCodeObservable.mapTo(Void()), _newCode)
            .startWith(Void())
            .flatMap { _ -> Observable<Int> in
                Observable.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .map { resendCodeTimeout - $0 - 1 }
                    .take(while: { $0 >= 0 })
            }
            .bind(to: _timer)
            .disposed(by: disposeBag)
        
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        isLoading = isLoadingRelay.asDriver()
        
        codeEvents.mapTo(false).bind(to: isLoadingRelay).disposed(by: disposeBag)
        validCodeObservable.mapTo(true).bind(to: isLoadingRelay).disposed(by: disposeBag)
        
        _getCode.asObservable().mapTo(true).bind(to: isLoadingRelay).disposed(by: disposeBag)
        fetchNewCode.mapTo(false).bind(to: isLoadingRelay).disposed(by: disposeBag)
        
        errors = codeEvents.errors()
            .merge(with: fetchNewCode.errors())
            .compactMap { ($0 as? ErrorType)?.localizedDescription }
            .asDriver(onErrorJustReturn: "")
    }
}
