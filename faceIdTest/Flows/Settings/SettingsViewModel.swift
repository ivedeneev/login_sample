//
//  SettingsViewModel.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.03.2021.
//

import Foundation
import RxSwift

protocol SettingsViewModelProtocol {
    var showEnablePin: AnyObserver<Void> { get }
    var didShowEnablePin: Observable<Void> { get }
    
    var enabledPinResult: AnyObserver<EnablePinResult> { get }
    var didCancelEnablePin: Observable<Void> { get }
    
    var editPin: AnyObserver<Void> { get }
    var showEditPin: Observable<Void> { get }
    
    var toggleBiometrics: AnyObserver<Bool> { get }
}

final class SettingsViewModel: SettingsViewModelProtocol {
    
    let showEnablePin: AnyObserver<Void>
    let didShowEnablePin: Observable<Void>
    
    let enabledPinResult: AnyObserver<EnablePinResult>
    let didCancelEnablePin: Observable<Void>
    
    let editPin: AnyObserver<Void>
    let showEditPin: Observable<Void>
    
    let toggleBiometrics: AnyObserver<Bool>
    
    private let disposeBag = DisposeBag()
    private let prefs: Preferences
    
    init(prefs: Preferences = Preferences()) {
        
        self.prefs = prefs
        
        let _enable = PublishSubject<Void>()
        showEnablePin = _enable.asObserver()
        didShowEnablePin = _enable.asObservable()
        
        let _didEnableResult = PublishSubject<EnablePinResult>()
        enabledPinResult = _didEnableResult.asObserver()
        didCancelEnablePin = _didEnableResult.asObservable().filter { $0 == .cancel }.mapToVoid()
        
        let _edit = PublishSubject<Void>()
        editPin = _edit.asObserver()
        showEditPin = _edit.asObservable()
        
        let _biometrics = PublishSubject<Bool>()
        toggleBiometrics = _biometrics.asObserver()
        
//        _biometrics.asObservable()
//            .debug()
//            .bind(to: prefs.rx.biometricsIsOn)
//            .disposed(by: disposeBag)
        _biometrics.asObservable()
            .debug()
            .bind(to: prefs.rx.keyPath(kp: \.biometricsIsOn))
            .disposed(by: disposeBag)
    }
}
