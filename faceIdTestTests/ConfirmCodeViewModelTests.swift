//
//  ConfirmCodeViewModelTests.swift
//  faceIdTestTests
//
//  Created by Igor Vedeneev on 23.03.2021.
//

import XCTest
import RxSwift
import RxBlocking

@testable import faceIdTest

class ConfirmCodeViewModelTests: XCTestCase {
    
    private let disposeBag = DisposeBag()
    
    func testCreateCode() throws {
       let viewModel = ConfirmCodeViewModel(
        token: "fdfsd",
        phone: "79153051653",
        codeLength: 4,
        authService: MockAuthService()
       )
        
        let text = Observable.from(["2", "23", "234", "2345"])
        text.bind(to: viewModel.code).disposed(by: disposeBag)
        viewModel.didAuthorize.debug().subscribe().disposed(by: disposeBag)
//        XCTAssertEqual(try viewModel.numeratorText.toBlocking().first(), "4")
//        viewModel.isLoading.
        let ttt = try text.toBlocking().toArray()
        XCTAssertEqual(try viewModel.isLoading.toBlocking().toArray(), [false, true])
    }
    
    func testConfirmCode() throws {
        
    }
}

class MockAuthService: AuthServiceProtocol {
    func loginByPhone(phone: String) -> Observable<String> {
        .just("")
    }
    
    func confirmCode(code: String, token: String) -> Observable<AuthResult> {
        .just(.success)
    }
}
