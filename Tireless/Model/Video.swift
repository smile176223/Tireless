//
//  Video.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation

struct Video: Codable {
    let userId: String
    var video: String
    var videoURL: URL
    var createTime: Int64
    var content: String
    var comment: Comment?

    enum CodingKeys: String, CodingKey {
        case userId
        case video
        case videoURL
        case createTime
        case content
        case comment
    }
}

struct Comment: Codable {
    let userId: String
    var content: String
    var createTime: Int64
    
    enum CodingKeys: String, CodingKey {
        case userId
        case content
        case createTime
    }
}
