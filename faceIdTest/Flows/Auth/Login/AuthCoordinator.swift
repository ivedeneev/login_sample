//
//  AuthCoordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit
import RxSwift

final class AuthCoordinator: BaseCoordinator<AuthResult> {
    
    private let disposeBag = DisposeBag()
    
    init(_ window: UIWindow?) {
        super.init()
        
        rootViewController = TranslucentNavigationController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    override func start() -> Observable<AuthResult> {
        
        let loginVc = LoginViewController()
        let vm = LoginViewModel()
        loginVc.viewModel = vm
        (rootViewController as? UINavigationController)?.setViewControllers([loginVc], animated: false)
        
        return vm.tokenForPhoneNumber
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] (token, phone) -> Observable<AuthResult> in
                guard let self = self else { return .empty() }
                return self.confirmCode(token: token, phone: phone)
            }
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] result -> Observable<AuthResult> in
                guard let self = self else { return .empty() }
                
                switch result {
                case .needPersonalData:
                    return self.showFillPersonalData()
                case .success:
                    return .just(.success)
                }
            }
    }
    
    private func confirmCode(token: String, phone: String) -> Observable<AuthResult> {
        let coordinator = ConfirmCodeCoordinator(token: token, phone: phone, nc: rootViewController)
        return coordinate(to: coordinator)
    }
    
    private func showFillPersonalData() -> Observable<AuthResult> {
        let coordinator = PersonalDataCoordinator(nc: rootViewController)
        return coordinate(to: coordinator)
    }
}


class TranslucentNavigationController: UINavigationController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewControllers.last?.supportedInterfaceOrientations ?? .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        navigationBar.tintColor = Color.text()
    }
}
