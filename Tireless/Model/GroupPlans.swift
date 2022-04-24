//
//  GroupPlans.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

struct GroupPlans: Codable {
    var planName: String
    var planTimes: String
    var planDays: String
    var createdTime: Int64
    var createdUserId: String
    var uuid: String
    
    enum CodingKeys: String, CodingKey {
        case planName
        case planTimes
        case planDays
        case createdTime
        case createdUserId
        case uuid
    }
}

extension GroupPlans: Hashable {
    static func == (lhs: GroupPlans, rhs: GroupPlans) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
