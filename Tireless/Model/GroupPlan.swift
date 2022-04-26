//
//  GroupPlans.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

struct GroupPlan: Codable {
    var planName: String
    var planTimes: String
    var planDays: String
    var planGroup: Bool
    var createdTime: Int64
    var createdUserId: String
    var joinUserId: [String]
    var uuid: String
    
    enum CodingKeys: String, CodingKey {
        case planName
        case planTimes
        case planDays
        case planGroup
        case createdTime
        case createdUserId
        case joinUserId
        case uuid
    }
}

extension GroupPlan: Hashable {
    static func == (lhs: GroupPlan, rhs: GroupPlan) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
