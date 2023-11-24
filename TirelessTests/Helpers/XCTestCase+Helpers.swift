//
//  XCTestCase+Helpers.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/24.
//

import XCTest

extension XCTestCase {
    var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    var anyEmail: String {
        "any@gmail.com"
    }
    
    var anyPassword: String {
        "any password"
    }
}

