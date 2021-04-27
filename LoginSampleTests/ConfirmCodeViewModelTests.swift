//
//  ConfirmCodeViewModelTests.swift
//  faceIdTestTests
//
//  Created by Igor Vedeneev on 23.03.2021.
//

import XCTest
import RxSwift
import RxTest
@testable import LoginSample

class ConfirmCodeViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    var service: MockAuthService!
    var viewModel: ConfirmCodeViewModel!
    var isLoading: TestableObserver<Int>!
    var codeInputEvents: TestableObservable<String>!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        service = MockAuthService()
        viewModel = ConfirmCodeViewModel(
            token: "fdfsd",
            phone: "79999999999",
            codeLength: 4,
            authService: service,
            timerScheduler: scheduler
        )
    }
    
    func test_didAuthorizeEmmitsValueAtSuccess() throws {
        bindCodeInputEvents()
        setConfirmCodeResult(.next(0, AuthResult.success))
        
        let sut = scheduler.start { self.viewModel.didAuthorize }
        XCTAssertEqual(sut.events, [.next(400, AuthResult.success)])
    }
    
    func test_errorEmmitedValueAtFailure() throws {
        bindCodeInputEvents()
        setConfirmCodeResult(.error(0, MockError.confirmFailure))

        let sut = scheduler.start { self.viewModel.errors }
        XCTAssertEqual(sut.events, [.next(400, "confirmFailure")])
    }
    
    func test_errorCanEmmitMoreThenOneTime() {
        bindCodeInputEvents([.next(100, "1"), .next(200, "11"), .next(300, "111"), .next(400, "1111"), .next(700, "2222")])
        setConfirmCodeResult(.error(0, MockError.confirmFailure))
        
        let sut = scheduler.start { self.viewModel.errors }
        XCTAssertEqual(sut.events, [.next(400, "confirmFailure"), .next(700, "confirmFailure")])
    }
    
    /// subscribed at 200
    func test_isLoadingInvokedCorrectlyAtSuccess() {
        bindCodeInputEvents()
        let sut = scheduler.start { self.viewModel.isLoading }
        XCTAssertEqual(sut.events, [.next(200, false), .next(400, true), .next(400, false)])
    }
    
    /// subscribed at 200
    func test_timerInvokedAutomatically() {
        let sut = scheduler.start(created: 0, subscribed: 0, disposed: 1000) { self.viewModel.newCodeTimer }
        XCTAssertEqual(sut.events, [.next(1, 2), .next(2, 1), .next(3, 0)])
    }
    
    func test_timerInvokedAfterResendCode() {
        let resendInputEvents = scheduler.createHotObservable([.next(600, ())])
        setConfirmCodeResult(.next(0, AuthResult.success))
        
        service.loginObservable = scheduler.createColdObservable(
            [.next(0, "()")]
        ).asObservable()
        
        resendInputEvents.bind(to: viewModel.getNewCode).disposed(by: disposeBag)
        
        let sut = scheduler.start() { self.viewModel.newCodeTimer }
        XCTAssertEqual(
            sut.events.suffix(3),
            [.next(601, 2), .next(602, 1), .next(603, 0)]
        )
    }
    
    func test_codeTimerIsActiveEmmitsCorrectly() {
        let sut = scheduler.start(created: 0, subscribed: 0, disposed: 1000) { self.viewModel.codeTimerIsActive }
        XCTAssertEqual(sut.events, [.next(0, true), .next(3, false)])
    }
    
    //MARK:- Helpers
    private func bindCodeInputEvents(
        _ events: [Recorded<Event<String>>] = [.next(100, "1"), .next(200, "11"), .next(300, "111"), .next(400, "1111")])
    {
        codeInputEvents = scheduler.createHotObservable(events)
        codeInputEvents.bind(to: viewModel.code).disposed(by: disposeBag)
    }
    
    private func setConfirmCodeResult(_ e: Recorded<Event<AuthResult>>) {
        service.confirmObservable = scheduler.createColdObservable([e]).asObservable()
    }
}

class MockAuthService: AuthServiceProtocol {
    var confirmObservable: Observable<AuthResult> = .empty()
    var loginObservable: Observable<String> = .empty()
    
    func loginByPhone(phone: String) -> Observable<String> {
        loginObservable
    }
    
    func confirmCode(code: String, token: String) -> Observable<AuthResult> {
        confirmObservable
    }
}

enum MockError: Error, ErrorType {
    var localizedDescription: String {
        "confirmFailure"
    }
    
    case confirmFailure
}
