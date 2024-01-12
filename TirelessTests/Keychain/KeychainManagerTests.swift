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
        let data = UserItem(id: "any id", email: "any email", name: "any name", picture: nil)
        try save(.userItem, with: data)
        
        let retrieveData = try retrieve(.userItem)
        XCTAssertEqual(retrieveData, data)
        
        try delete(.userItem)
        let dataAfterDelete = try retrieve(.userItem)
        XCTAssertEqual(dataAfterDelete, nil)
    }
    
    // MARK: - Helpers
    
    private func save<T: Codable>(_ key: KeychainManager.Key, with data: T) throws {
        try KeychainManager.save(key, with: data)
    }
    
    private func retrieve(_ key: KeychainManager.Key) throws -> UserItem? {
        let data: UserItem? = try KeychainManager.retrieve(key)
        return data
    }
    
    private func delete(_ key: KeychainManager.Key) throws {
        try KeychainManager.delete(key)
    }
}
