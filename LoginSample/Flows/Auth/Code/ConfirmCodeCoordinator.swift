//
//  ConfirmCodeCoordinator.swift
//  LoginSample
//
//  Created by Igor Vedeneev on 03.02.2021.
//

import UIKit
import RxSwift

final class ConfirmCodeCoordinator: BaseCoordinator<AuthResult> {
    
    private let token: String
    private let phone: String
    
    init(token: String, phone: String, nc: UIViewController?) {
        self.token = token
        self.phone = phone
        super.init()
        rootViewController = nc
    }
    
    override func start() -> Observable<AuthResult> {
        let vc = ConfirmCodeViewController()
        let vm = ConfirmCodeViewModel(token: token, phone: phone)
        vc.viewModel = vm
        (rootViewController as? UINavigationController)?.pushViewController(vc, animated: true)
        return vm.didAuthorize.asObservable()
    }
}
