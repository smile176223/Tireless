//
//  PlanMangeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class FetchPlanViewModel {
    
    var personalPlan = Box([PersonalPlan]())

    func fatchPlan() {
        PlanManager.shared.fetchPlan { result in
            switch result {
            case .success(let personalPlan):
                self.personalPlan.value = personalPlan
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deletePlan(uuid: String) {
        PlanManager.shared.deletePlan(uuid: uuid) { result in
            switch result {
            case .success(let uuid):
                print(uuid)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updatePlan(personalPlan: PersonalPlan) {
        PlanManager.shared.updatePlan(personalPlan: personalPlan) { result in
            switch result {
            case .success(let success):
                print(success)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
