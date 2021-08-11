//
//  MapCoordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Resolver

final class MapCoordinator: BaseCoordinator<Void> {
    
    weak var window: UIWindow?
    private let disposeBag = DisposeBag()
    @Injected var preferences: PreferencesProtocol
    
    init(_ window: UIWindow?) {
        super.init()
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let vc = MapViewController()
        let vm = MapViewModel()
        vc.viewModel = vm
        rootViewController = TranslucentNavigationController(rootViewController: vc)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        vm.didShowProfile
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.showProfile()
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        vm.configureRoute
            .flatMap { [weak self] (from, to) -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.showRideConfiguration(fromAddress: from, toAddress: to)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        vm.didShowPaymentMethods
            .flatMap { [weak self] _ -> Observable<PaymentMethod> in
                guard let self = self else { return .empty() }
                return self.showPaymentMethods()
            }
            .do(onNext: { [weak self] _ in
                self?.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .bind(to: vm.paymentMethod)
            .disposed(by: disposeBag)
        
        
        let pinIsPresented = PublishRelay<Bool>()
        let showPinEvents = NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .mapTo(preferences.pinIsOn)
            .withLatestFrom(pinIsPresented.startWith(false), resultSelector: { $0 && !$1 })
            .filter { $0 }
            .share()
        
        showPinEvents.mapTo(true).bind(to: pinIsPresented).disposed(by: disposeBag)
        
        let pinEvents = showPinEvents
            .filter { $0 }
            .flatMapLatest { [weak self] _ -> Observable<EnablePinResult> in
                guard let self = self else { return .empty() }
                let c = ConfirmCodeCoordniator(rootViewController: self.rootViewController)
                c.animated = false
                return self.coordinate(to: c)
            }
            .share()
        
        pinEvents.mapTo(false).bind(to: pinIsPresented).disposed(by: disposeBag)
            
        pinEvents
            .withUnretained(self)
            .bind { coord, result in
                coord.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        return .never()
    }
    
    private func showProfile() -> Observable<Void> {
        let coordinator = ProfileCoordinator(rootViewController)
        return coordinate(to: coordinator)
    }
    
    private func showRideConfiguration(fromAddress: Address, toAddress: Address?) -> Observable<Void> {
        let coordinator = ConfigureRideCoordinator(startPoint: fromAddress, endPoint: toAddress, rootVc: rootViewController)
        return coordinate(to: coordinator)
    }
    
    private func showPaymentMethods() -> Observable<PaymentMethod> {
        let coordinator = SelectPaymentMethodCoordinator(rootVc: rootViewController)
        return coordinate(to: coordinator).compactMap {
            switch $0 {
            case .method(let method):
                return method
            case .dismissed:
                return nil
            }
        }
    }
    
//    private func showRideConfirmation() -> Observable<Void> {
//
//    }
}

extension Observable {
    func printElements(prefix: String = "") -> Observable<Element> {
        self.do(onNext: { print(prefix, $0) })
    }
}
