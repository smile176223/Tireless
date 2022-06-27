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

struct UserId: Codable {
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case userId
    }
}
