//
//  Video.swift
//  Tireless
//
//  Created by Hao on 2022/4/13.
//

import Foundation

struct Video: Codable {
    let id: String
    let video: String
    let videoURL: URL

    enum CodingKeys: String, CodingKey {
        case id
        case video
        case videoURL
    }
}
