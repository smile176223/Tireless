//
//  GroupPlanStatusViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/5/2.
//

import Foundation

class GroupPlanStatusViewModel {
    
    let groupPlanStatusViewModels = Box([PlanViewModel]())
    
    func fetchGroupPlanStatus(plan: Plan) {
        PlanManager.shared.checkGroupUsersStatus(plan: plan) { result in
            switch result {
            case .success(let plans):
                self.setPlans(plans)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func convertPlansToViewModels(from plans: [Plan]) -> [PlanViewModel] {
        var viewModels = [PlanViewModel]()
        for plan in plans {
            let viewModel = PlanViewModel(model: plan)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setPlans(_ plans: [Plan]) {
        groupPlanStatusViewModels.value = convertPlansToViewModels(from: plans)
    }
}
