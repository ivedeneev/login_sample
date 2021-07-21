//
//  LoginViewModelTests.swift
//  faceIdTestTests
//
//  Created by Igor Vedeneev on 21.07.2021.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest
@testable import faceIdTest

class LoginViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    var service: MockAuthService!
    var viewModel: LoginViewModel!
    var isLoading: TestableObserver<Int>!
    var phoneInputEvents: TestableObservable<String>!
    
    override func setUp() {
        super.setUp()
        print("SET UP")
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        service = MockAuthService()
        viewModel = LoginViewModel(authService: service)
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = DisposeBag()
    }
    
    func test_didLoginEmmitsValueOnSuccess() {
        let token = "test_token"
        let phone = "79153051653"
        bindInputs(phone: phone)
        setConfirmCodeResult(.next(0, token))
        
        
        let sut = scheduler.start { self.viewModel.tokenForPhoneNumber }
        XCTAssertEqual(sut.events, [.next(2000, LoginOutput(token: token, phone: phone))])
    }
    
    func bindInputs(phone: String) {
        let events: [Recorded<Event<String>>] = (1...phone.count).map { i in
            .next(200 + 100 * i, String(phone.prefix(i)))
        }
        print(events.map { $0.value })
        phoneInputEvents = scheduler.createHotObservable(events)
        phoneInputEvents.bind(to: viewModel.phoneNumber).disposed(by: disposeBag)
    }
    
    private func setConfirmCodeResult(_ e: Recorded<Event<String>>) {
        service.loginObservable = scheduler.createColdObservable([e]).asObservable()
    }
}
