//
//  ProfileViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

class ProfileViewModel {
    
    var userInfo = Box([User]())
    
    let historyPlanViewModels = Box([HistoryPlanViewModel]())

    func fetchUser(userId: String) {
        UserManager.shared.fetchUser(userId: userId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.userInfo.value = [user]
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchHistoryPlan() {
        PlanManager.shared.fetchHistoryPlan(userId: AuthManager.shared.currentUser) { [weak self] result in
            switch result {
            case .success(let plans):
                self?.setHistoryPlan(plans)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func convertPlansToViewModels(from plans: [Plan]) -> [HistoryPlanViewModel] {
        var viewModels = [HistoryPlanViewModel]()
        for plan in plans {
            let viewModel = HistoryPlanViewModel(model: plan)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setHistoryPlan(_ plans: [Plan]) {
        historyPlanViewModels.value = convertPlansToViewModels(from: plans)
    }
}
