//
//  GroupPlans.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

struct GroupPlanUser: Codable {
    var joinUsers: [String]
    
    enum CodingKeys: String, CodingKey {
        case joinUsers
    }
}
