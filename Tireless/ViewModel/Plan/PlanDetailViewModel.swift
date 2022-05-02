//
//  PlanManageViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanDetailViewModel {
    
    var plan: Plan = Plan(planName: "",
                          planTimes: "",
                          planDays: "",
                          createdTime: -1,
                          planGroup: false,
                          progress: 0.0,
                          finishTime: [],
                          uuid: "")
    
    func setPlanData(name: String, times: String, days: String, createdTime: Int64, planGroup: Bool) {
        self.plan.planName = name
        self.plan.planTimes = times
        self.plan.planDays = days
        self.plan.createdTime = createdTime
        self.plan.planGroup = planGroup
    }
    
    func createPlan(success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        PlanManager.shared.createPlan(userId: AuthManager.shared.currentUser, plan: &plan) { result in
            switch result {
            case .success:
                success()
                ProgressHUD.showSuccess(text: "建立成功!")
            case .failure(let error):
                failure(error)
                ProgressHUD.showFailure()
            }
        }
    }
}
