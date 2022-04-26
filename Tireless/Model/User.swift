//
//  User.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import Foundation

struct User: Codable {
    var emailAccount: String
    var userId: String
    var name: String
    var picture: String
    var maxVideoUploadCount: Int
    
    enum CodingKeys: String, CodingKey {
        case emailAccount
        case userId
        case name
        case picture
        case maxVideoUploadCount
    }
}

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
}

struct UserId: Codable {
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case userId
    }
}
