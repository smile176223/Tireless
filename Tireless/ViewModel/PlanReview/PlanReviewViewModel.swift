//
//  PlanReviewViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/5/5.
//

import Foundation

class PlanReviewViewModel {
    let finishTimeViewModels = Box([FinishTimeViewModel]())
    
    func fetchPlanReview(finishTime: [FinishTime]) {
        PlanManager.shared.fetchPlanReviewVideo(finishTime: finishTime) { result in
            switch result {
            case .success(let finish):
                self.setPlans(finish)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func convertFinishTimeToViewModels(from finishTime: [FinishTime]) -> [FinishTimeViewModel] {
        var viewModels = [FinishTimeViewModel]()
        for finish in finishTime {
            let viewModel = FinishTimeViewModel(model: finish)
            viewModels.append(viewModel)
        }
        return viewModels

    }
    
    func setPlans(_ finishTime: [FinishTime]) {
        finishTimeViewModels.value = convertFinishTimeToViewModels(from: finishTime)
    }
    
}
