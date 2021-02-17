//
//  Settings.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 10.02.2021.
//

import Foundation

///  Обертка над `UserDefaults` для настроек, которые не требуют особой безопасности
///  Пример исппользования:
///  ```
///  `@Setting<Bool>("didShowOnboarding", defaultValue: false)
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
            return getValue()
        }
        set {
            setValue(newValue)
        }
    }
    
    private func getValue() -> T {
        userDefaults.object(forKey: key) as? T ?? defaultValue
    }
    
//    private func getValue() -> T where T: RawRepresentable {
//        guard let value = userDefaults.value(forKey: key) as? T.RawValue else {
//            return defaultValue
//        }
//
//        return T(rawValue: value) ?? defaultValue
//    }
    
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
        // почему-то крашится, если там nil
        userDefaults.set(newValue, forKey: key)
    }
    
//    private func setValue(_ newValue: T) where T: RawRepresentable {
//        userDefaults.set(newValue.rawValue, forKey: key)
//    }
}
