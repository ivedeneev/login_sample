//
//  AuthCoordinator.swift
//  LoginSample
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit
import RxSwift

final class AuthCoordinator: BaseCoordinator<Void> {
    
    private let disposeBag = DisposeBag()
    
    init(_ window: UIWindow?) {
        super.init()
        
        rootViewController = UINavigationController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    override func start() -> Observable<Void> {
        
        let loginVc = LoginViewController()
        let vm = LoginViewModel()
        loginVc.viewModel = vm
        (rootViewController as? UINavigationController)?.setViewControllers([loginVc], animated: false)
        
        vm.tokenForPhoneNumber
            .flatMap { [weak self] (token) -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.confirmCode(token: token)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        return .never()
    }
    
    private func confirmCode(token: String) -> Observable<String> {
        (rootViewController as? UINavigationController)?.pushViewController(ConfirmCodeViewController(), animated: true)
        return .empty()
    }
}
