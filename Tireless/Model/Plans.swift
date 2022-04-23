//
//  Plan.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

struct WeeklyDays: Hashable {
    let days: String
    let weekDays: String
}

struct Plans: Hashable {
    let planName: String
    let planDetail: String
    let planImage: String
    let planLottie: String
}

struct PlanManage: Codable {
    var planName: String
    var planTimes: String
    var planDays: String
    var createdTime: Int64
    var planGroup: Bool
    var progress: Double
    var finishTime: [FinishTime?]
    var uuid: String
    
    enum CodingKeys: String, CodingKey {
        case planName
        case planTimes
        case planDays
        case createdTime
        case planGroup
        case progress
        case finishTime
        case uuid
    }
}

extension PlanManage: Hashable {
    static func == (lhs: PlanManage, rhs: PlanManage) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

struct FinishTime: Codable {
    let day: Int
    let time: Int64
}
