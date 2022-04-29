//
//  PlanMangeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanManageViewModel {
    
    var plan = Box([Plan]())
    
    var groupPlan = Box([GroupPlan]())

    func fetchPlan() {
        PlanManager.shared.fetchPlan(userId: AuthManager.shared.currentUser) { result in
            switch result {
            case .success(let plan):
                self.plan.value = plan
                
            case .failure(let error):
                print(error)
            }
        }
        PlanManager.shared.fetchGroupPlan { result in
            switch result {
            case .success(let groupPlan):
                self.groupPlan.value = groupPlan
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deletePlan(uuid: String) {
        PlanManager.shared.deletePlan(userId: AuthManager.shared.currentUser, uuid: uuid) { result in
            switch result {
            case .success(let uuid):
                print(uuid)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updatePlan(plan: Plan) {
        PlanManager.shared.updatePlan(userId: AuthManager.shared.currentUser, plan: plan) { result in
            switch result {
            case .success(let success):
                if plan.progress == 1 {
                    self.deletePlan(uuid: plan.uuid)
                }
                print(success)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func finishPlan(plan: Plan) {
        PlanManager.shared.finishPlan(userId: AuthManager.shared.currentUser, plan: plan) { result in
            switch result {
            case .success(let success):
                print(success)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
