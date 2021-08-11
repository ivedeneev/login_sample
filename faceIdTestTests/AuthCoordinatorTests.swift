//
//  AuthCoordinatorTests.swift
//  faceIdTestTests
//
//  Created by Igor Vedeneev on 21.07.2021.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest
@testable import faceIdTest

class AuthCoordinatorTests: XCTestCase {
    
    var coordinator: AuthCoordinator!
    
    override func setUp() {
        super.setUp()
        coordinator = AuthCoordinator(nil)
    }
    
    func test_successAuthFlow() {
        
    }
}
