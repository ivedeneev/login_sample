//
//  AppCoordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit
import RxSwift

final class AppCoordinator: BaseCoordinator<Void> {
    
    private var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
   
    override func start() -> Observable<Void> {
        let isLoggedIn = false
        
        if isLoggedIn {
            
            return coordinate(to: MainCoordinator(window))
        } else {
            return coordinate(to: AuthCoordinator(window))
                .flatMap { [weak self] _ -> Observable<Void> in
                    guard let self = self else { return .empty() }
                    
                    return self.coordinate(to: MainCoordinator(self.window))
                }
        }
    }
}

final class MainCoordinator: BaseCoordinator<Void> {
    private var window: UIWindow?
    
    init(_ window: UIWindow?) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        window?.rootViewController = UINavigationController(
            rootViewController: UITableViewController()
        )
        
        return .never()
    }
}
