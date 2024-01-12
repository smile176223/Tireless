//
//  Codable+Helpers.swift
//  Tireless
//
//  Created by Liam on 2023/11/29.
//

import Foundation

public extension Encodable {
    subscript(key: String) -> Any? {
        return dict[key]
    }
    
    var dict: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self), options: .allowFragments)) as? [String: Any] ?? [:]
    }
}
