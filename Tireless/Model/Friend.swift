//
//  Friends.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

struct Friend: Codable {
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case userId
    }
}
