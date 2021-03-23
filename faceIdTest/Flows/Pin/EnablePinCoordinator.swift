//
//  EnablePinCoordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 18.02.2021.
//

import UIKit
import RxSwift

enum EnablePinResult {
    case enabled
    case cancel
}

final class EnablePinCoordinator: BaseCoordinator<EnablePinResult> {
    
    var animated = true
    
    override func start() -> Observable<EnablePinResult> {
        let type = PinCodeType.create
        let vm = PinCodeViewModel(pinType: type)
        let vc = PinCodeController()
        vc.viewModel = vm

        rootViewController?.present(vc, animated: animated, completion: nil)
        
        return vm.didAuthenticate.mapTo(EnablePinResult.enabled)
            .merge(with: vc.rx.deallocated.mapTo(EnablePinResult.cancel))
            .take(1)
    }
}

final class EditPinCoordinator: BaseCoordinator<EnablePinResult> {
    
    override func start() -> Observable<EnablePinResult> {
        let type = PinCodeType.confirm
        let vm = PinCodeViewModel(pinType: type)
        let vc = PinCodeController()
        vc.viewModel = vm

        rootViewController?.present(vc, animated: true, completion: nil)
        
        return vm.didAuthenticate.mapTo(EnablePinResult.enabled)
            .merge(with: vc.rx.deallocated.mapTo(EnablePinResult.cancel))
            .take(1)
            .observe(on: MainScheduler.instance)
            .flatMapLatest { result -> Observable<EnablePinResult> in
                guard result == .enabled else { return .just(.cancel) }
                
                return Observable.create { (obs) -> Disposable in
                    vc.dismiss(animated: true) {
                        obs.onNext(result)
                        obs.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .flatMapLatest { [unowned self] (result) -> Observable<EnablePinResult> in
                guard result == .enabled else { return .just(result) }
                
                let c = EnablePinCoordinator(rootViewController: self.rootViewController)
                return self.coordinate(to: c)
            }
    }
}

final class RemovePinCoordinator: BaseCoordinator<EnablePinResult> {
    
    override func start() -> Observable<EnablePinResult> {
        let type = PinCodeType.confirm
        let vm = PinCodeViewModel(pinType: type)
        let vc = PinCodeController()
        vc.viewModel = vm

        rootViewController?.present(vc, animated: true, completion: nil)
        
        return vm.didAuthenticate.mapTo(EnablePinResult.enabled)
            .merge(with: vc.rx.deallocated.mapTo(EnablePinResult.cancel))
            .take(1)
            .flatMapLatest { result -> Observable<EnablePinResult> in
                guard result == .enabled else { return .just(.cancel) }
                
                return Observable.create { (obs) -> Disposable in
                    vc.dismiss(animated: true) {
                        obs.onNext(result)
                        obs.onCompleted()
                    }
                    return Disposables.create()
                }
            }
    }
}

final class ConfirmCodeCoordniator: BaseCoordinator<EnablePinResult> {
    override func start() -> Observable<EnablePinResult> {
        let type = PinCodeType.confirm
        let vm = PinCodeViewModel(pinType: type)
        let vc = PinCodeController()
        vc.viewModel = vm

        rootViewController?.present(vc, animated: true, completion: nil)
        
        return vm.didAuthenticate.mapTo(EnablePinResult.enabled)
            .merge(with: vc.rx.deallocated.mapTo(EnablePinResult.cancel))
            .take(1)
    }
}


//        vm.didAuthenticate.subscribe { [unowned self] _ in
//            let title = type.needsConfirmation ? "Код создан" : "Код подтвержден"
//
//            let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
//            ac.addAction(.init(title: "Продолжить", style: .cancel, handler: { [unowned self] _ in
//                self.rootViewController?.dismiss(animated: true, completion: nil)
//            }))
//            vc.present(ac, animated: true, completion: nil)
//        }
//        .disposed(by: disposeBag)
