//
//  XCTestCase+Helpers.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/24.
//

import XCTest
import Tireless

extension XCTestCase {
    var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    var anyAuthError: AuthError {
        .customError("any error")
    }
    
    var anyEmail: String {
        "any@gmail.com"
    }
    
    var anyPassword: String {
        "any password"
    }
    
    var anyUserId: String {
        "any userId"
    }
    
    var anyName: String {
        "any name"
    }
    
    var anyUserData: Data {
        let json = """
        {"userId": "\(anyUserId)", "email": "\(anyEmail)", "name": "\(anyName)"}
        """
        return Data(json.utf8)
    }
}

/// Make Dictionary Equatable
public func ==<K, L: Any, R: Any>(lhs: [K: L], rhs: [K: R]) -> Bool {
    (lhs as NSDictionary).isEqual(to: rhs)
}
