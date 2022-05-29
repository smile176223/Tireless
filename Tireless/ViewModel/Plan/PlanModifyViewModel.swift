//
//  PlanModifyViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/5/28.
//

import Foundation

class PlanModifyViewModel {
    
    var plan: Plan
    
    init(plan: Plan) {
        self.plan = plan
    }
    
    func modifyPlan(times: String, success: (() -> Void)?) {
        PlanManager.shared.modifyPlan(planUid: plan.uuid,
                                      times: times) { result in
            switch result {
            case .success:
                ProgressHUD.showSuccess(text: "修改計畫成功")
                success?()
            case .failure:
                ProgressHUD.showFailure()
            }
        }
    }
}
