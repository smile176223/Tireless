//
//  PlanMangeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class FetchPlanViewModel {
    
    var planManage = Box([PlanManage]())

    func fatchPlan() {
        PlanManager.shared.fetchPlan { result in
            switch result {
            case .success(let planManage):
                self.planManage.value = planManage
                
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
}
