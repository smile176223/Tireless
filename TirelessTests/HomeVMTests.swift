//
//  HomeVMTests.swift
//  TirelessTests
//
//  Created by Hao on 2022/6/13.
//

import XCTest
@testable import Tireless

class MockDayData: DateFormatter {
    
}

class HomeVMTests: XCTestCase {
    var sut: HomeViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = HomeViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testSetupDay() throws {
        
        var target: String?
        
        target = sut.setupDay()
        
        XCTAssertEqual(target, "Test", "wrong")
        
    }

    func testPerformanceExample() throws {
        
        self.measure {
            
        }
    }

}
