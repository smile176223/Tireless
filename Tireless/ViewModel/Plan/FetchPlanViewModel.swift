//
//  PlanMangeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class FetchPlanViewModel {
    
    var personalPlan = Box([PersonalPlan]())
    
    var groupPlan = Box([GroupPlan]())

    func fatchPlan() {
        PlanManager.shared.fetchPlan(userId: DemoUser.demoUser) { result in
            switch result {
            case .success(let personalPlan):
                self.personalPlan.value = personalPlan
                
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
        PlanManager.shared.deletePlan(userId: DemoUser.demoUser, uuid: uuid) { result in
            switch result {
            case .success(let uuid):
                print(uuid)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updatePlan(personalPlan: PersonalPlan) {
        PlanManager.shared.updatePlan(userId: DemoUser.demoUser, personalPlan: personalPlan) { result in
            switch result {
            case .success(let success):
                print(success)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
