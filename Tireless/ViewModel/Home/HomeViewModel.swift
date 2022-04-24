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
                       planDetail:
                        "深蹲，又稱蹲舉，在力量練習中，是個複合的、全身性的練習動作，它可以訓練到大腿、臀部、大腿後肌，同時可以增強骨頭、韌帶和橫貫下半身的肌腱。",
                       planImage: "pexels_squat",
                       planLottie: "Squat"),
                 Plans(planName: "棒式",
                       planDetail:
                        "平板支撐又稱撐高、撐舉、棒式或撐平板，是一種等長核心強度運動，會讓身體維持在一個費力的姿勢，且要維持相當一段時間。",
                       planImage: "pexels_plank",
                       planLottie: "Plank"),
                 Plans(planName: "伏地挺身",
                       planDetail:
                        "伏地挺身主要鍛鍊的肌肉群有胸大肌和肱三頭肌，同時還鍛鍊三角肌前束、前鋸肌和喙肱肌及身體的其他部位。",
                       planImage: "pexels_pushup",
                       planLottie: "Pushup")]
    
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