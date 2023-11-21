//
//  AppleSignInControllerTests.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/21.
//

import XCTest
import Combine
import AuthenticationServices
@testable import Tireless

class AppleSignInControllerTests: XCTestCase {

    func test_authenticate_performsProperRequest() {
        let spy = ASAuthorizationController.spy
        let sut = AppleSignInController()
        
        _ = sut.authenticate(spy, nonce: "any")
        
        XCTAssertTrue(spy.delegate === sut)
        XCTAssertEqual(spy.performRequestsCallCount, 1)
    }
}

extension ASAuthorizationController {
    static var spy: Spy {
        let dummyRequest = ASAuthorizationAppleIDProvider().createRequest()
        return Spy(authorizationRequests: [dummyRequest])
    }
    
    class Spy: ASAuthorizationController {
        private(set) var performRequestsCallCount = 0
        
        override func performRequests() {
            performRequestsCallCount += 1
        }
    }
}
