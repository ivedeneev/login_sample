//
//  LoginViewModel.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import Resolver

struct LoginOutput: Equatable {
    let token: String
    let phone: String
}

protocol LoginViewModelProtocol {
    var phoneNumber: AnyObserver<String> { get }
    var resendPhone: AnyObserver<Void> { get }
    var tokenForPhoneNumber: Observable<LoginOutput> { get }
    var isLoading: Driver<Bool> { get }
    var errors: Driver<String?> { get }
}

final class LoginViewModel: LoginViewModelProtocol {
    var isLoading: Driver<Bool>
    var errors: Driver<String?>
    
    
    var phoneNumber: AnyObserver<String>
    var resendPhone: AnyObserver<Void>
    var tokenForPhoneNumber: Observable<LoginOutput>
    
//    @Injected var _authService: AuthServiceProtocol
    
    private let disposeBag = DisposeBag()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        let _phoneSubject = PublishSubject<String>()
        phoneNumber = _phoneSubject.asObserver()
        
        let _resendSubject = PublishSubject<Void>()
        resendPhone = _resendSubject.asObserver()
        
        let phoneObservable = _phoneSubject.asObservable().share()
        
        let validPhoneObservable = phoneObservable
            .merge(with: _resendSubject.withLatestFrom(phoneObservable))
            .filter { $0.isValidPhone }
        
        let phoneEvents = validPhoneObservable
            .flatMapLatest { (phone) in
                authService.loginByPhone(phone: phone).materialize()
            }
            .share()
        
        tokenForPhoneNumber = phoneEvents.elements()
            .withLatestFrom(
                validPhoneObservable,
                resultSelector: { LoginOutput(token: $0, phone: $1) }
            )

        
        let _isLoading = BehaviorRelay<Bool>(value: false)
        isLoading = _isLoading.asDriver()
        
        let _errors = BehaviorRelay<String?>(value: nil)
        errors = _errors.asDriver()
        
        phoneEvents.mapTo(false).bind(to: _isLoading).disposed(by: disposeBag)
        validPhoneObservable.mapTo(true).bind(to: _isLoading).disposed(by: disposeBag)
        
        phoneEvents.errors()
            .compactMap { ($0 as? ErrorType)?.localizedDescription }
            .bind(to: _errors)
            .disposed(by: disposeBag)
        
        phoneObservable.mapTo(nil).bind(to: _errors).disposed(by: disposeBag)
    }
}
