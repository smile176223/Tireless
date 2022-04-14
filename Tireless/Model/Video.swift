//
//  Video.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation

struct Video: Codable {
    let userId: String
    let video: String
    let videoURL: URL
    let createTime: Int64
    let content: String
    let comment: Comment?

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
    let content: String
    let createTime: Int64
    
    enum CodingKeys: String, CodingKey {
        case userId
        case content
        case createTime
    }
}
