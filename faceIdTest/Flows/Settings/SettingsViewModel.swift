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
}

final class SettingsViewModel: SettingsViewModelProtocol {
    
    let showEnablePin: AnyObserver<Void>
    let didShowEnablePin: Observable<Void>
    
    let enabledPinResult: AnyObserver<EnablePinResult>
    let didCancelEnablePin: Observable<Void>
    
    let editPin: AnyObserver<Void>
    let showEditPin: Observable<Void>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let _enable = PublishSubject<Void>()
        showEnablePin = _enable.asObserver()
        didShowEnablePin = _enable.asObservable()
        
        let _didEnableResult = PublishSubject<EnablePinResult>()
        enabledPinResult = _didEnableResult.asObserver()
        didCancelEnablePin = _didEnableResult.asObservable().filter { $0 == .cancel }.mapToVoid()
        
        let _edit = PublishSubject<Void>()
        editPin = _edit.asObserver()
        showEditPin = _edit.asObservable()
        
    }
}
