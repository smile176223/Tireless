//
//  Plan.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

struct Plan: Hashable {
    let planName: String
    let planDetail: String
    let planImage: String
}

struct PlanManage: Codable {
    var planName: String
    var planTimes: String
    var planDays: String
    var createdTime: Int64
    var planGroup: Bool
    var progress: Double
    
    enum CodingKeys: String, CodingKey {
        case planName
        case planTimes
        case planDays
        case createdTime
        case planGroup
        case progress
    }
}
