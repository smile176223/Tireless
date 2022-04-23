//
//  HomeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class HomeViewModel {
    
    let personalPlan = Box([Plans]())
    
    var plans = [Plans(planName: "深蹲",
                       planDetail: "深蹲",
                       planImage: "pexels_squat"),
                 Plans(planName: "棒式",
                       planDetail: "棒式",
                       planImage: "pexels_plank"),
                 Plans(planName: "伏地挺身",
                       planDetail: "伏地挺身",
                       planImage: "pexels_pushup")]
    
    lazy var weeklyDay = [WeeklyDays(days: "\(countDaily(-2))", weekDays: countWeekDay(-2)),
                          WeeklyDays(days: "\(countDaily(-1))", weekDays: countWeekDay(-1)),
                          WeeklyDays(days: "\(countDaily(0))", weekDays: countWeekDay(0)),
                          WeeklyDays(days: "\(countDaily(1))", weekDays: countWeekDay(1)),
                          WeeklyDays(days: "\(countDaily(2))", weekDays: countWeekDay(2))]
    
    func setDefault() {
        self.personalPlan.value = plans
    }
    
    private func countDaily(_ day: Int) -> Int {
        let calendar = Calendar.current.date(byAdding: .day, value: day, to: Date())
        return calendar?.get(.day) ?? 0
    }
    
    private func countWeekDay(_ day: Int) -> String {
        guard let calendar = Calendar.current.date(byAdding: .day, value: day, to: Date()) else { return ""}
        let weekDayString = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return weekDayString[calendar.get(.weekday) - 1]
    }
}
