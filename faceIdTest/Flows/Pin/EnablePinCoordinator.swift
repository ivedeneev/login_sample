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
    
    init(root: UIViewController?) {
        super.init()
        rootViewController = root
    }
    
    override func start() -> Observable<EnablePinResult> {
        Observable.create { [rootViewController] observer in
            let ac = UIAlertController(title: "Добавить вход по коду?", message: nil, preferredStyle: .actionSheet)
            
            ac.addAction(
                .init(title: "Добавить", style: .default, handler: { _ in
                    observer.onNext(.enabled)
                    observer.onCompleted()
                }
            ))
            
            ac.addAction(
                .init(title: "Позже", style: .default, handler: { _ in
                    observer.onNext(.cancel)
                    observer.onCompleted()
                }
            ))
            
            rootViewController?.present(ac, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
}
