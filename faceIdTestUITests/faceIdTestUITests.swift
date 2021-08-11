//
//  faceIdTestUITests.swift
//  faceIdTestUITests
//
//  Created by Igor Vedeneev on 09.08.2021.
//

import XCTest
import Resolver
@testable import faceIdTest


class faceIdTestUITests: XCTestCase {
    
    var resolver = Resolver()
    var prefs = MockPrefs.shared

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testManualPinCode() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTS"]
        app.launchEnvironment = ["pinCode" : "1111", "pinIsOn" : "true"]
        app.launch()
        
        let five = app/*@START_MENU_TOKEN@*/.staticTexts["5"]/*[[".otherElements[\"pin_pad_5\"].staticTexts[\"5\"]",".staticTexts[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let one = app.staticTexts["1"]
        XCTAssert(five.exists && one.exists)
        one.tap()
        one.tap()
        one.tap()
        one.tap()

        let favPlacesCv = app.collectionViews["fav_places"]
        
        XCTAssertTrue(favPlacesCv.exists)
        XCTAssertTrue(favPlacesCv.isHittable)
    }
    
    func testFaceId() {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTS"]
        app.launchEnvironment = ["pinCode" : "1111", "pinIsOn" : "true", "biometricsIsEnabled" : "true"]
        app.launch()
        
        
    }
    
    func testCompleteAuth() {
        let app = XCUIApplication()
        app.launch()
        
        /// Input phone >
        /// input code >
        /// enable pin >
        /// accept face id >
        /// RESULTS:
        /// pin is on, face id is on
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
