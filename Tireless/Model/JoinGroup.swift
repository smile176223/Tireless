//
//  JoinGroups.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import Foundation

struct JoinGroup: Codable {
    var planName: String
    var planTimes: String
    var planDays: String
    var planGroup: Bool
    var createdTime: Int64
    var createdUserId: String
    var createdUser: User?
    var uuid: String
    
    enum CodingKeys: String, CodingKey {
        case planName
        case planTimes
        case planDays
        case planGroup
        case createdTime
        case createdUserId
        case createdUser
        case uuid
    }
}

extension JoinGroup: Hashable {
    static func == (lhs: JoinGroup, rhs: JoinGroup) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
