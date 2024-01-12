//
//  KeychainManager.swift
//  Tireless
//
//  Created by Liam on 2024/1/8.
//

import Foundation

public struct KeychainManager {
    private static let service = "com.app.keychain.manager"
    
    public enum KeychainError: Error {
        case saveError
        case deleteError
        
        var message: String {
            switch self {
            case .saveError: "Save to keychain error"
            case .deleteError: "Delete in keychain error"
            }
        }
    }
    
    public enum Key {
        case userItem
        
        var string: String {
            switch self {
            case .userItem: "userItem"
            }
        }
    }
    
    public static func save<T: Codable>(_ key: Key, with data: T) throws {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            
            var query: [String: Any] = [
                KeychainConstant.kSecClass: kSecClassGenericPassword,
                KeychainConstant.kSecAttrService: service,
                KeychainConstant.kSecAttrAccount: key.string
            ]

            SecItemDelete(query as CFDictionary)
            
            query[KeychainConstant.kSecValueData] = jsonData
            let status = SecItemAdd(query as CFDictionary, nil)
            
            if status != errSecSuccess {
                throw KeychainError.saveError
            }
        } catch {
            throw error
        }
    }
    
    public static func retrieve<T: Codable>(_ key: Key) throws -> T? {
        var query: [String: Any] = [
            KeychainConstant.kSecClass: kSecClassGenericPassword,
            KeychainConstant.kSecAttrService: service,
            KeychainConstant.kSecAttrAccount: key.string,
            KeychainConstant.kSecMatchLimit: kSecMatchLimitOne
        ]
        query[KeychainConstant.kSecReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw error
            }
        } else {
            return nil
        }
    }
    
    public static func delete(_ key: Key) throws {
        let query: [String: Any] = [
            KeychainConstant.kSecClass: kSecClassGenericPassword,
            KeychainConstant.kSecAttrService: service,
            KeychainConstant.kSecAttrAccount: key.string
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess {
            throw KeychainError.deleteError
        }
    }
}

struct KeychainConstant {
    
    static var kSecClass: String { return toString(Security.kSecClass) }
    static var kSecAttrService: String { return toString(Security.kSecAttrService) }
    static var kSecAttrAccount: String { return toString(Security.kSecAttrAccount) }
    static var kSecMatchLimit: String { return toString(Security.kSecMatchLimit) }
    static var kSecReturnData: String { return toString(Security.kSecReturnData) }
    static var kSecValueData: String { return toString(Security.kSecValueData) }
    
    private static func toString(_ value: CFString) -> String {
        return value as String
    }
}
