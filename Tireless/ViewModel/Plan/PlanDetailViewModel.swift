//
//  PlanManageViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanDetailViewModel {
    
    var planManage: PlanManage = PlanManage(planName: "",
                                            planTimes: "",
                                            planDays: "",
                                            createdTime: -1,
                                            planGroup: false,
                                            progress: 0.0,
                                            uuid: "")
    
    func getPlanData(name: String, times: String, days: String, createdTime: Int64, planGroup: Bool) {
        self.planManage.planName = name
        self.planManage.planTimes = times
        self.planManage.planDays = days
        self.planManage.createdTime = createdTime
        self.planManage.planGroup = planGroup
    }
    
    func createPlan(success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        PlanManager.shared.createPlan(planManage: &planManage) { result in
            switch result {
            case .success:
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }
}
