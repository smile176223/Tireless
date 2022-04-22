//
//  PlanManageViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanDetailViewModel {
    
    let planManager = PlanManager()
    
    var planManage: PlanManage = PlanManage(planName: "",
                                            planTimes: "",
                                            planDays: "",
                                            createdTime: -1,
                                            planGroup: false,
                                            progress: 0.0)
    
    func getPlanData(name: String, times: String, days: String, createdTime: Int64, planGroup: Bool) {
        self.planManage.planName = name
        self.planManage.planTimes = times
        self.planManage.planDays = days
        self.planManage.createdTime = createdTime
        self.planManage.planGroup = planGroup
    }
    
    func createPlan() {
        PlanManager.shared.createPlan(plan: planManage) { result in
            switch result {
            case .success:
                print("success")
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
