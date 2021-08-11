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
import Resolver

class LoginViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    var service: MockAuthService!
    var viewModel: LoginViewModel!
    var isLoading: TestableObserver<Int>!
    var phoneInputEvents: TestableObservable<String>!
    var token: String!
    var phone: String!
    var resolver: Resolver!
    
    override func setUp() {
        super.setUp()
        print("SET UP")
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        service = MockAuthService()
        viewModel = LoginViewModel(authService: service)
        token = "test_token"
        phone = "79153051653"
        
        resolver = Resolver()
        resolver.register { MockAuthService() as AuthServiceProtocol }
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = DisposeBag()
    }
    
    func test_isLoading() {
        bindInputs()
        setConfirmCodeResult(.next(30, token))
        
        let sut = scheduler.start(created: 0, subscribed: 0, disposed: 500) { self.viewModel.isLoading }
        XCTAssertEqual(sut.events, [.next(0, false), .next(320, true), .next(350, false)])
    }
    
    func test_didLoginEmmitsValueOnSuccess() {
        bindInputs()
        setConfirmCodeResult(.next(0, token))
        
        let sut = scheduler.start { self.viewModel.tokenForPhoneNumber }
        // 100 + 11 * 20
        XCTAssertEqual(sut.events, [.next(320, LoginOutput(token: token, phone: phone))])
    }
    
    func bindInputs() {
        let events: [Recorded<Event<String>>] = (1...phone.count).map { i in
            .next(100 + 20 * i, String(phone.prefix(i)))
        }

        phoneInputEvents = scheduler.createHotObservable(events)
        phoneInputEvents.bind(to: viewModel.phoneNumber).disposed(by: disposeBag)
    }
    
    private func setConfirmCodeResult(_ e: Recorded<Event<String>>) {
        service.loginObservable = scheduler.createColdObservable([e]).asObservable()
    }
}
