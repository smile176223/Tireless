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
    
    let selectPlan: Box<DefaultPlans?> = Box(nil)
    
    var defaultPlans: [DefaultPlans]
    
    init(defaultPlans: [DefaultPlans]) {
        self.defaultPlans = defaultPlans
    }
    
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
    
    func createPlan(times: String, days: String, success: @escaping (() -> Void), needLogin: (() -> Void)?) {
        if AuthManager.shared.checkCurrentUser() {
            guard let planName = selectPlan.value?.planName,
                  let createdName = AuthManager.shared.currentUserData?.name  else {
                return
            }
            getPlanData(name: planName,
                        times: times,
                        days: days,
                        createdName: createdName,
                        createdUserId: AuthManager.shared.currentUser)
            
            JoinGroupManager.shared.createJoinGroup(joinGroup: &joinGroup) { result in
                switch result {
                case .success:
                    success()
                    ProgressHUD.showSuccess(text: "建立成功")
                case .failure:
                    ProgressHUD.showFailure()
                }
            }
        } else {
            needLogin?()
        }
    }
    
    func userSelectPlan(index: IndexPath) {
        selectPlan.value = defaultPlans[index.row]
    }
    
    func getCurrentUserName() -> String {
        if let name = AuthManager.shared.currentUserData?.name {
            return name
        } else {
            return "User"
        }
    }
}
