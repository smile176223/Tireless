//
//  SetGroupPlanViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import Foundation

class SetGroupPlanViewModel {
    
    var joinGroup: JoinGroup = JoinGroup(planName: "",
                                         planTimes: "",
                                         planDays: "",
                                         planGroup: true,
                                         createdTime: -1,
                                         createdUserId: "",
                                         uuid: "")
    
    func getPlanData(name: String,
                     times: String,
                     days: String,
                     createdName: String,
                     createdUserId: String) {
        self.joinGroup.planName = name
        self.joinGroup.planTimes = times
        self.joinGroup.planDays = days
        self.joinGroup.createdTime = Date().millisecondsSince1970
        self.joinGroup.createdUserId = createdUserId
    }
    
    func createPlan(success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        JoinGroupManager.shared.createJoinGroup(joinGroup: &joinGroup) { result in
            switch result {
            case .success:
                success()
                ProgressHUD.showSuccess(text: "建立成功")
            case .failure(let error):
                failure(error)
                ProgressHUD.showFailure()
            }
        }
    }
}
