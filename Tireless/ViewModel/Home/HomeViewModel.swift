//
//  HomeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class HomeViewModel {
    
    let personalPlan = Box([Plan]())

    var plans = [Plan(planName: "Squat",
                      planDetail: "",
                      planImage: "pexels_squat"),
                 Plan(planName: "Plank",
                      planDetail: "",
                      planImage: "pexels_plank"),
                 Plan(planName: "PushUp",
                      planDetail: "",
                      planImage: "pexels_pushup")]
    
    func setDefault() {
        self.personalPlan.value = plans
    }
}
