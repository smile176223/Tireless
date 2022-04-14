//
//  User.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import Foundation

struct User: Codable {
    let emailAccount: String
    let name: String
    let token: String
    let picture: String
    let maxVideoUploadCount: Int
    
    enum CodingKeys: String, CodingKey {
        case emailAccount
        case name
        case token
        case picture
        case maxVideoUploadCount
    }
}
