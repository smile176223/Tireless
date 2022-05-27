//
//  PlanManageViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanDetailViewModel {
    
    let isCreatePlan: Box<Bool?> = Box(nil)
    
    let isUserLogin: Box<Bool?> = Box(nil)
    
    var defaultPlans: DefaultPlans
    
    init(defaultPlans: DefaultPlans) {
        self.defaultPlans = defaultPlans
    }
    
    func createPlan(times: String, days: String) {
        if AuthManager.shared.checkCurrentUser() == true {
            self.isUserLogin.value = false
            var plan = Plan(planName: defaultPlans.planName,
                            planTimes: times,
                            planDays: days,
                            createdTime: Date().millisecondsSince1970,
                            planGroup: false,
                            progress: 0.0,
                            finishTime: [],
                            uuid: "")
            PlanManager.shared.createPlan(userId: AuthManager.shared.currentUser,
                                          plan: &plan) { result in
                switch result {
                case .success:
                    ProgressHUD.showSuccess(text: "建立成功")
                    self.isCreatePlan.value = true
                case .failure(let error):
                    ProgressHUD.showFailure()
                    self.isCreatePlan.value = false
                    print(error)
                }
            }
        } else {
            self.isUserLogin.value = true
        }
    }
}
