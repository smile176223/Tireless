//
//  KeychainManagerTests.swift
//  TirelessTests
//
//  Created by Liam on 2024/1/8.
//

import XCTest
import Tireless

class KeychainManagerTests: XCTestCase {
    
    func test_save_keychainSuccessfully() throws {
        let data = AuthData(email: "any@gmail.com", userId: "any userid", name: "any name")
        try save(.authData, with: data)
        
        let retrieveData = try retrieve(.authData)
        XCTAssertEqual(retrieveData, data)
        
        try delete(.authData)
        let dataAfterDelete = try retrieve(.authData)
        XCTAssertEqual(dataAfterDelete, nil)
    }
    
    // MARK: - Helpers
    
    private func save<T: Codable>(_ key: KeychainManager.Key, with data: T) throws {
        try KeychainManager.save(key, with: data)
    }
    
    private func retrieve(_ key: KeychainManager.Key) throws -> AuthData? {
        let data: AuthData? = try KeychainManager.retrieve(key)
        return data
    }
    
    private func delete(_ key: KeychainManager.Key) throws {
        try KeychainManager.delete(key)
    }
}
