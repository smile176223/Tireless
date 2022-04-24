//
//  Friends.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

struct Friends: Codable {
    let userId: String
    let name: String
    let picture: String
    
    enum CodingKeys: String, CodingKey {
        case userId
        case name
        case picture
    }
}

extension Friends: Hashable {
    static func == (lhs: Friends, rhs: Friends) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
}
