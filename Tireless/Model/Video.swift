//
//  Video.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation

struct Video: Codable {
    var userId: String
    var videoName: String
    var videoURL: URL
    var createdTime: Int64
    var content: String
    var comment: Comment?

    enum CodingKeys: String, CodingKey {
        case userId
        case videoName
        case videoURL
        case createdTime
        case content
        case comment
    }
}

struct Comment: Codable {
    let userId: String
    let content: String
    let createdTime: Int64
    
    enum CodingKeys: String, CodingKey {
        case userId
        case content
        case createdTime
    }
}
