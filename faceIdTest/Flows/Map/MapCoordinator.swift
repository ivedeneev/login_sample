//
//  MapCoordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 04.02.2021.
//

import UIKit
import RxSwift

final class MapCoordinator: BaseCoordinator<Void> {
    
    weak var window: UIWindow?
    private let disposeBag = DisposeBag()
    
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
        
        return .never()
    }
    
    private func showProfile() -> Observable<Void> {
        let vm = PinCodeViewModel(config: .init(needsRepeat: false, showForgotPassword: true, isBiometricsAvailable: true))
        let vc = PinCodeController()
        vc.viewModel = vm
        rootViewController?.present(vc, animated: true, completion: nil)
        return .empty()
//        let coordinator = ProfileCoordinator(rootViewController)
//        return coordinate(to: coordinator)
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
