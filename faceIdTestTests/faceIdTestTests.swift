//
//  faceIdTestTests.swift
//  faceIdTestTests
//
//  Created by Igor Vedeneev on 25.02.2021.
//

import XCTest
import RxSwift
import RxRelay

class CellViewModel1 {
    var title: String!
    var onTap = PublishRelay<Void>()
    
    init(title: String) {
        self.title = title
    }
}


class CellViewModel2 {
    var title: String!
    var onTap: () -> ()
    
    init(title: String, onTap: @escaping () -> ()) {
        self.title = title
        self.onTap = onTap
    }
}


class faceIdTestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        var arr = [CellViewModel1]()
        measure {
            for _ in 0..<5000 {
                let vm = CellViewModel1(title: "asd")
                arr.append(vm)
            }
        }
    }
    
    func testPerformanceExample2() throws {
        var arr = [CellViewModel2]()
        measure {
            for _ in 0..<5000 {
                let vm = CellViewModel2(title: "asd", onTap: {print("asd")})
                arr.append(vm)
            }
            stopMeasuring()
        }
    }
}

extension XCTestCase{
    /// Executes the block and return the execution time in millis
    public func timeBlock(closure: ()->()) -> Int{
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        let begin = mach_absolute_time()

        closure()

        let diff = Double(mach_absolute_time() - begin) * Double(info.numer) / Double(1_000_000 * info.denom)
        return Int(diff)
    }
}
