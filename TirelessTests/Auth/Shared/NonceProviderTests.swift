//
//  NonceProviderTests.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/24.
//

import XCTest
import Tireless

class NonceProviderTests: XCTestCase {
    
    func test_generateNonce() {
        let sut = NonceProvider()
        
        let nonce = sut.generateNonce()
        
        XCTAssertFalse(nonce.raw.isEmpty)
        XCTAssertFalse(nonce.sha256.isEmpty)
        XCTAssertEqual(nonce.raw.count, 32)
        XCTAssertEqual(nonce.sha256.count, 64)
    }
}
