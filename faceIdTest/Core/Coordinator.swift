//
//  Coordinator.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 02.02.2021.
//

import UIKit
import RxSwift

protocol CoordinatorProtocol {
    var rootViewController: UIViewController? { get }
}

class BaseCoordinator<T>: CoordinatorProtocol {
       var rootViewController: UIViewController?
    
    convenience init(rootViewController: UIViewController?) {
        self.init()
        self.rootViewController = rootViewController
    }
    
       private let identifier = UUID()

       /// Dictionary of the child coordinators. Every child coordinator should be added
       /// to that dictionary in order to keep it in memory.
       /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
       /// Value type is `Any` because Swift doesn't allow to store generic types in the array.
       private var childCoordinators = [UUID: CoordinatorProtocol]()


       /// Stores coordinator to the `childCoordinators` dictionary.
       ///
       /// - Parameter coordinator: Child coordinator to store.
       private func store<T>(coordinator: BaseCoordinator<T>) {
           childCoordinators[coordinator.identifier] = coordinator
       }

       /// Release coordinator from the `childCoordinators` dictionary.
       ///
       /// - Parameter coordinator: Coordinator to release.
       private func free<T>(coordinator: BaseCoordinator<T>) {
           childCoordinators[coordinator.identifier] = nil
       }

       /// 1. Stores coordinator in a dictionary of child coordinators.
       /// 2. Calls method `start()` on that coordinator.
       /// 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
       ///
       /// - Parameter coordinator: Coordinator to start.
       /// - Returns: Result of `start()` method.
       func coordinate<T>(to coordinator: BaseCoordinator<T>) -> Observable<T> {
           store(coordinator: coordinator)
           return coordinator.start()
//            .takeLast(1)
//            .do(onNext: { [weak self] _ in
//                self?.free(coordinator: coordinator)
//            })
            .do(onDispose: { [weak self] in
                #if DEBUG
                print("free \(coordinator)")
                #endif
                self?.free(coordinator: coordinator)
            })
       }

       /// Starts job of the coordinator.
       ///
       /// - Returns: Result of coordinator job.
       func start() -> Observable<T> {
           fatalError("Start method should be implemented.")
       }
}
