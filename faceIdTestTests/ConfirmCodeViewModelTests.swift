//
//  ConfirmCodeViewModelTests.swift
//  faceIdTestTests
//
//  Created by Igor Vedeneev on 23.03.2021.
//

import XCTest
import RxSwift
import RxBlocking
//import RxTest
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
        viewModel.didAuthorize.do(onNext: { _ in
                                    print("T_T")
        }).subscribe().disposed(by: disposeBag)
        
        text.bind(to: viewModel.code).disposed(by: disposeBag)
//        XCTAssertEqual(try viewModel.numeratorText.toBlocking().first(), "4")
//        viewModel.isLoading.
        let ttt = try viewModel.didAuthorize.toBlocking().toArray()
//        XCTAssertEqual(try viewModel.didAuthorize.toBlocking().toArray(), [false, true])
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
