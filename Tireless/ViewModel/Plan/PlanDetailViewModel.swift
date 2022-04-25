//
//  PlanManageViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanDetailViewModel {
    
    var personalPlan: PersonalPlan = PersonalPlan(planName: "",
                                            planTimes: "",
                                            planDays: "",
                                            createdTime: -1,
                                            planGroup: false,
                                            progress: 0.0,
                                            finishTime: [],
                                            uuid: "")
    
    func getPlanData(name: String, times: String, days: String, createdTime: Int64, planGroup: Bool) {
        self.personalPlan.planName = name
        self.personalPlan.planTimes = times
        self.personalPlan.planDays = days
        self.personalPlan.createdTime = createdTime
        self.personalPlan.planGroup = planGroup
    }
    
    func createPlan(success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        PlanManager.shared.createPlan(personalPlan: &personalPlan) { result in
            switch result {
            case .success:
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }
}
