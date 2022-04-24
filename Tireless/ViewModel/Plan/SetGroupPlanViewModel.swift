//
//  SetGroupPlanViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import Foundation

class SetGroupPlanViewModel {
    
    var groupPlan: GroupPlans = GroupPlans(planName: "",
                                           planTimes: "",
                                           planDays: "",
                                           createdTime: -1,
                                           createdUserId: "",
                                           createdName: "",
                                           uuid: "")
    
    func getPlanData(name: String,
                     times: String,
                     days: String,
                     createdName: String,
                     createdUserId: String) {
        self.groupPlan.planName = name
        self.groupPlan.planTimes = times
        self.groupPlan.planDays = days
        self.groupPlan.createdTime = Date().millisecondsSince1970
        self.groupPlan.createdName = createdName
        self.groupPlan.createdUserId = createdUserId
    }
    
    func createPlan(success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        GroupPlanManager.shared.createGroupPlan(groupPlan: &groupPlan) { result in
            switch result {
            case .success:
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }
}
