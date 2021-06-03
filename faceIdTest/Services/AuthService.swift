//
//  AuthService.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 03.02.2021.
//

import Foundation
import RxSwift
import UserNotifications

protocol AuthServiceProtocol {
    func loginByPhone(phone: String) -> Observable<String>
    func confirmCode(code: String, token: String) -> Observable<AuthResult>
}

final class AuthService: AuthServiceProtocol {
    func loginByPhone(phone: String) -> Observable<String> {
        Observable<String>.create { (obs) -> Disposable in
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
                let content = UNMutableNotificationContent()
                content.body = "Ваш код: 1337"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) {(error) in
                    if let error = error {
                        #if DEBUG
                        print("scheduled notification error: \(error)")
                        #endif
                    }
                }

                
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
                    if token == "+7 (915) 305-16-53" {
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

//enum ErrorType: Error {
//    case text(String)
//
//    var localizedDescription: String {
//        switch self {
//        case .text(let text):
//            return text
//        default:
//            break
//        }
//    }
//}

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
