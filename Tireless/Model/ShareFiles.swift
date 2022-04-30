//
//  Video.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation

struct ShareFiles: Codable {
    var userId: String
    var shareName: String
    var shareURL: URL
    var createdTime: Int64
    var content: String
    var uuid: String

    enum CodingKeys: String, CodingKey {
        case userId
        case shareName
        case shareURL
        case createdTime
        case content
        case uuid
    }
}

struct Comment: Codable {
    let userId: String
    let content: String
    let createdTime: Int64
    var user: User? = nil
    
    enum CodingKeys: String, CodingKey {
        case userId
        case content
        case createdTime
        case user
    }
}
