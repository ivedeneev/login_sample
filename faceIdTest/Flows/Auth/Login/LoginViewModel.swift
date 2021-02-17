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

typealias LoginOutput = (token: String, phone: String)

protocol LoginViewModelProtocol {
    var phoneNumber: AnyObserver<String> { get }
    var resendPhone: AnyObserver<Void> { get }
    var tokenForPhoneNumber: Observable<LoginOutput> { get }
    var isLoading: BehaviorRelay<Bool> { get }
    var errors: BehaviorRelay<String?> { get }
}

final class LoginViewModel: LoginViewModelProtocol {
    
    var phoneNumber: AnyObserver<String>
    var resendPhone: AnyObserver<Void>
    var tokenForPhoneNumber: Observable<LoginOutput>
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errors = BehaviorRelay<String?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        let _phoneSubject = PublishSubject<String>()
        phoneNumber = _phoneSubject.asObserver()
        
        let _resendSubject = PublishSubject<Void>()
        resendPhone = _resendSubject.asObserver()
        
        let phoneObservable = _phoneSubject.asObservable().share()
        
        let validPhoneObservable = phoneObservable
            .merge(with: _resendSubject.asObservable()
            .withLatestFrom(phoneObservable))
            .filter { $0.isValidPhone }
        
        let phoneEvents = validPhoneObservable
            .flatMapLatest { (phone) in
                authService.loginByPhone(phone: phone).materialize()
            }.share()
        
        tokenForPhoneNumber = phoneEvents.elements()
            .withLatestFrom(
                validPhoneObservable,
                resultSelector: { LoginOutput(token: $0, phone: $1) }
            )
        
        phoneEvents.mapTo(false).bind(to: isLoading).disposed(by: disposeBag)
        validPhoneObservable.mapTo(true).bind(to: isLoading).disposed(by: disposeBag)
        
        phoneEvents.errors()
            .compactMap { ($0 as? ErrorType)?.localizedDescription }
            .bind(to: errors).disposed(by: disposeBag)
        
        phoneObservable.mapTo(Optional<String>.none).bind(to: errors).disposed(by: disposeBag)
    }
}
