//
//  PlanMangeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanManageViewModel {
    
    var personalPlan = Box([PersonalPlan]())
    
    var groupPlan = Box([GroupPlan]())

    func fetchPlan() {
        PlanManager.shared.fetchPlan(userId: UserManager.shared.currentUser) { result in
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
        PlanManager.shared.deletePlan(userId: UserManager.shared.currentUser, uuid: uuid) { result in
            switch result {
            case .success(let uuid):
                print(uuid)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updatePlan(personalPlan: PersonalPlan) {
        PlanManager.shared.updatePlan(userId: UserManager.shared.currentUser, personalPlan: personalPlan) { result in
            switch result {
            case .success(let success):
                if personalPlan.progress == 1 {
                    self.deletePlan(uuid: personalPlan.uuid)
                }
                print(success)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func finishPlan(personalPlan: PersonalPlan) {
        PlanManager.shared.finishPlan(userId: UserManager.shared.currentUser, personalPlan: personalPlan) { result in
            switch result {
            case .success(let success):
                print(success)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
