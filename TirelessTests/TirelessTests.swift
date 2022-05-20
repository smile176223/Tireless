//
//  TirelessTests.swift
//  TirelessTests
//
//  Created by Hao on 2022/5/19.
//

import XCTest
@testable import Tireless

class TirelessTests: XCTestCase {
    var sut: SquatManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SquatManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBaseline() throws {
        let posePoint = PosePoint(position: CGPoint(x: 13, y: 1), zPoint: CGFloat(1), inFrameLikelihood: 1, type: "")
        let baseline = CGFloat(10)
        var bool: Bool?
        
        bool = sut.checkBaseline(posePoint, baseline)
        
        XCTAssertEqual(bool, true, "wtf")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
