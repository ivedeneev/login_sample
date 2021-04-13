//
//  AuthService.swift
//  LoginSample
//
//  Created by Igor Vedeneev on 03.02.2021.
//

import Foundation
import RxSwift

protocol AuthServiceProtocol {
    func loginByPhone(phone: String) -> Observable<String>
    func confirmCode(code: String, token: String) -> Observable<AuthResult>
}

final class AuthService: AuthServiceProtocol {
    func loginByPhone(phone: String) -> Observable<String> {
        Observable<String>.create { (obs) -> Disposable in
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
                obs.onNext(phone)
                obs.onCompleted()
//                obs.onError(ErrorType.text("Ошибка сервера. Попробовать еще раз"))
            }
            
            return Disposables.create()
        }
    }
    
    func confirmCode(code: String, token: String) -> Observable<AuthResult> {
        Observable<AuthResult>.create { (obs) -> Disposable in
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
                
                if code == "1111" {
                    if token == "+7 (999) 999-99-99" {
                        obs.onNext(AuthResult.success)
                    } else {
                        obs.onNext(AuthResult.needPersonalData)
                    }
                    
                    obs.onCompleted()
                } else {
                    obs.onError(AuthErrorType.atempsLeft(3))
                }
            }
            
            return Disposables.create()
        }
    }
}

protocol ErrorType {
    var localizedDescription: String { get }
}

enum AuthErrorType: Error, ErrorType {
    case atempsLeft(Int)
    case blocked
    
    var localizedDescription: String {
        switch self {
        case .atempsLeft(let left):
            return "Код введен неверно. Осталось \(left) попыток"
        case .blocked:
            return "Вход заблокирован, попробуйте позднее"
        }
    }
}
