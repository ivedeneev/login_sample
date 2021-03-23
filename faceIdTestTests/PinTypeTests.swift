//
//  PinTypeTests.swift
//  faceIdTestTests
//
//  Created by Igor Vedeneev on 25.02.2021.
//

import XCTest
@testable import faceIdTest

class PinTypeTests: XCTestCase {
    
    func testCreateCode() throws {
        let createCode: PinCodeType = .create
        XCTAssertEqual(createCode.canForceLogout, false)
        XCTAssertEqual(createCode.canUseBiometrics, false)
        XCTAssertEqual(createCode.needsConfirmation, true)
    }
    
    func testConfirmCode() throws {
        let createCode: PinCodeType = .confirm
        XCTAssertEqual(createCode.canForceLogout, true)
        XCTAssertEqual(createCode.canUseBiometrics, true)
        XCTAssertEqual(createCode.needsConfirmation, false)
    }
}
