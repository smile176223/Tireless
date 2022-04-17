//
//  Picture.swift
//  Tireless
//
//  Created by Hao on 2022/4/17.
//

import Foundation

struct Picture: Codable {
    var userId: String
    var pictureName: String
    var pictureURL: URL
    var createdTime: Int64
    var content: String
    var comment: Comment?

    enum CodingKeys: String, CodingKey {
        case userId
        case pictureName
        case pictureURL
        case createdTime
        case content
        case comment
    }
}
