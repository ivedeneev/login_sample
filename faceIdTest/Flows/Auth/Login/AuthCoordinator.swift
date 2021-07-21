//
//  AuthCoordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit
import RxSwift

final class AuthCoordinator: BaseCoordinator<AuthResult> {
    
    deinit {
        print("AuthCoordinator")
    }
    
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
            .flatMapLatest(confirmCode)
            .flatMapLatest(showFillPersonalDataIfNeeded)
            .flatMapLatest(enablePinAndFaceId)
            .take(1)
    }
    
    private func confirmCode(loginOutput: LoginOutput) -> Observable<AuthResult> {
        let coordinator = ConfirmCodeCoordinator(
            token: loginOutput.token,
            phone: loginOutput.phone,
            nc: rootViewController
        )
        return coordinate(to: coordinator)
    }
    
    /// предложить вход по пин-коду -> создать пин -> предложить добавить FaceID -> добавить FaceID
    func enablePinAndFaceId(authResult: AuthResult) -> Observable<AuthResult> {
        suggestEnablePin()
            .flatMapLatest { [unowned self] needToEnable -> Observable<EnablePinResult> in
                guard needToEnable else { return .just(.cancel) }
                return self.enablePin()
            }
            .flatMapLatest { [unowned self] (r) -> Observable<AuthResult> in
                guard r == .enabled else { return .just(authResult) }
                
                return self.enableFaceID().mapTo(authResult)
            }
    }
    
    func enablePin() -> Observable<EnablePinResult> {
        let c = EnablePinCoordinator(rootViewController: rootViewController)
        return coordinate(to: c)
    }
    
    private func showFillPersonalDataIfNeeded(authResult: AuthResult) -> Observable<AuthResult> {
        switch authResult {
        case .needPersonalData:
            let coordinator = PersonalDataCoordinator(nc: rootViewController)
            return coordinate(to: coordinator)
        case .success:
            return .just(.success)
        }
    }
    
    func suggestEnablePin() -> Observable<Bool> {
        Observable.create { [rootViewController] observer in
            let ac = UIAlertController(title: "Добавить вход по коду?", message: "Вы можете добавить код позже в настройках", preferredStyle: .actionSheet)
            
            ac.addAction(
                .init(title: "Добавить", style: .default, handler: { _ in
                    observer.onNext(true)
                    observer.onCompleted()
                }
            ))
            
            ac.addAction(
                .init(title: "Позже", style: .default, handler: { _ in
                    observer.onNext(false)
                    observer.onCompleted()
                }
            ))
            
            rootViewController?.present(ac, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    func enableFaceID() -> Observable<Bool> {
        Observable.create { [rootViewController] observer in
            let ac = UIAlertController(title: "Использовать FaceID", message: "Вы можете изменить этот параметр позже в настройках", preferredStyle: .actionSheet)
            
            ac.addAction(
                .init(title: "Добавить", style: .default, handler: { _ in
                    observer.onNext(true)
                    observer.onCompleted()
                }
            ))
            
            ac.addAction(
                .init(title: "Позже", style: .default, handler: { _ in
                    observer.onNext(false)
                    observer.onCompleted()
                }
            ))
            
            rootViewController?.presentedViewController?.present(ac, animated: true, completion: nil)
            
            return Disposables.create()
        }
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
        
//        navigationBar.tintColor = Color.accent()
        navigationBar.tintColor = Color.text()
//        navigationBar.backIndicatorImage = Asset.backButtonIcon.image
//        navigationBar.backIndicatorTransitionMaskImage = Asset.backButtonIcon.image
    }
}


protocol VCFabric {
    associatedtype VCType
    
    static func make() -> VCType
}
