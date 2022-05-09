//
//  PlanMangeViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation

class PlanManageViewModel {
    
    let planViewModels = Box([PlanViewModel]())
    
    let groupPlanViewModels = Box([PlanViewModel]())
    
    func fetchPlan() {
        PlanManager.shared.fetchPlan(userId: AuthManager.shared.currentUser) { result in
            switch result {
            case .success(let plan):
                self.setPlans(plan)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deletePlan(plan: Plan) {
        PlanManager.shared.deletePlan(userId: AuthManager.shared.currentUser, plan: plan) { result in
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
                    self.deletePlan(plan: plan)
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
    
    func logoutReset() {
        setPlans([Plan]())
    }
    
    func convertPlansToViewModels(from plans: [Plan], isGroup: Bool) -> [PlanViewModel] {
        var viewModels = [PlanViewModel]()
        for plan in plans where plan.planGroup == isGroup {
            let viewModel = PlanViewModel(model: plan)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setPlans(_ plans: [Plan]) {
        planViewModels.value = convertPlansToViewModels(from: plans, isGroup: false)
        groupPlanViewModels.value = convertPlansToViewModels(from: plans, isGroup: true)
    }
}
