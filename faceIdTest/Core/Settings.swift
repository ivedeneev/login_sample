//
//  Settings.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 10.02.2021.
//

import Foundation
import RxSwift
import RxRelay

//protocol PreferencesProtocol: AnyObject {
//    var pinCode: String? { get set }
//    var pinIsOn: Bool { get set }
//    var biometricsIsOn: Bool { get set }
//}

final class Preferences {
    
    @Setting<String?>("pin_code", defaultValue: nil)
    var pinCode: String?
    
    @Setting<Bool>("pin_is_on", defaultValue: false)
    var pinIsOn: Bool
    
    @Setting<Bool>("biometrics_is_on", defaultValue: false)
    var biometricsIsOn: Bool
}

extension Preferences: ReactiveCompatible {}
extension Reactive where Base: Preferences {
//    var pinCode: Binder<String?> {
//        Binder(base) { (base, pin) in
//            base.pinCode = pin
//        }
//    }
//
//    var biometricsIsOn: Binder<Bool> {
//        Binder(base) { (base, isOn) in
//            base.biometricsIsOn = isOn
//        }
//    }
//    
    func keyPath<Value>(kp: WritableKeyPath<Base, Value>) -> Binder<Value> {
        Binder(base) { (base, value) in
            var b = base
            b[keyPath: kp] = value
        }
    }
}

///  Обертка над `UserDefaults` для настроек, которые не требуют особой безопасности
///  Пример исппользования:
///  ```
///  `@Setting<Bool>("did_show_onboarding", defaultValue: false)
///   var didShowOnboarding: Bool
///  ```
@propertyWrapper
struct Setting<T> {
    let key: String
    let defaultValue: T
    private let userDefaults: UserDefaults

    init(_ key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get {
            getValue()
        }
        set {
            setValue(newValue)
        }
    }
    
    private func getValue() -> T {
        userDefaults.object(forKey: key) as? T ?? defaultValue
    }
    
    private func setValue(_ newValue: T) {
        switch newValue {
        case let newValue as Optional<T>:
            switch newValue {
            case .none:
                userDefaults.removeObject(forKey: key)
                return
            default: break
            }
        default: break
        }

        userDefaults.set(newValue, forKey: key)
    }
    
    //    private func getValue() -> T where T: RawRepresentable {
    //        guard let value = userDefaults.value(forKey: key) as? T.RawValue else {
    //            return defaultValue
    //        }
    //
    //        return T(rawValue: value) ?? defaultValue
    //    }

    //    private func setValue(_ newValue: T) where T: RawRepresentable {
    //        userDefaults.set(newValue.rawValue, forKey: key)
    //    }
}
