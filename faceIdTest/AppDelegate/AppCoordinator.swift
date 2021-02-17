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
        let isLoggedIn = true
//        let isLoggedIn = false
        
        if isLoggedIn {
            return coordinate(to: MapCoordinator(window))
        } else {
            return coordinate(to: AuthCoordinator(window))
                .flatMap { [weak self] _ -> Observable<Void> in
                    guard let self = self else { return .empty() }
                    
                    return self.coordinate(to: MapCoordinator(self.window))
                }
        }
    }
}
