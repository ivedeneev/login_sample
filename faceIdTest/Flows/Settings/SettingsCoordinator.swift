//
//  SettingsCoordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.03.2021.
//

import UIKit
import RxSwift

final class SettingsCoordinator: BaseCoordinator<Void> {
    
    private let disposeBag = DisposeBag()
    
    override init() {
        print("settings c init")
    }

    override func start() -> Observable<Void> {
        let vc = SettingsViewController()
        let vm = SettingsViewModel()
        vc.viewModel = vm
        
        vm.didShowEnablePin
            .flatMapLatest { [unowned self] in
                self.showEnablePin()
            }
            .do(onNext: { [unowned self] result in
                guard result == .enabled else { return }
                self.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .bind(to: vm.enabledPinResult)
            .disposed(by: disposeBag)
        
        vm.showEditPin
            .flatMapLatest { [unowned self] in
                self.showEditPin()
            }
            .do(onNext: { [unowned self] result in
                guard result == .enabled else { return }
                self.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .bind(to: vm.enabledPinResult)
            .disposed(by: disposeBag)
        
        (rootViewController as? UINavigationController)?.pushViewController(vc, animated: true)
        
        return vc.rx.deallocated
    }
    
    private func showEnablePin() -> Observable<EnablePinResult> {
        let c = EnablePinCoordinator(rootViewController: rootViewController)
        return coordinate(to: c)
    }
    
    private func showEditPin() -> Observable<EnablePinResult> {
        let c = EditPinCoordinator(rootViewController: rootViewController)
        return coordinate(to: c)
    }
}
