//
//  Plan.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation
import UIKit

struct WeeklyDays: Hashable {
    let days: String
    let weekDays: String
}

// for default plans
struct DefaultPlans: Hashable {
    let planName: String
    let planDetail: String
    let planImage: String
    let planLottie: String
}

struct Plan: Codable {
    var planName: String
    var planTimes: String
    var planDays: String
    var createdTime: Int64
    var planGroup: Bool
    var progress: Double
    var finishTime: [FinishTime]
    var uuid: String
    var user: User?
    
    enum CodingKeys: String, CodingKey {
        case planName
        case planTimes
        case planDays
        case createdTime
        case planGroup
        case progress
        case finishTime
        case uuid
        case user
    }
}

struct FinishTime: Codable {
    let day: Int
    let time: Int64
    let planTimes: String
    var videoId: String?
    var videoURL: String?
}
