//
//  EditProfileViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/5/29.
//

import Foundation

class EditProfileViewModel {
    
    let userName = AuthManager.shared.currentUserData?.name
    
    func changeUserName(name: String, isCheck: (() -> Void)?) {
        ProfileManager.shared.changeUserName(name: name) { result in
            switch result {
            case .success:
                AuthManager.shared.getCurrentUser { result in
                    switch result {
                    case .success:
                        isCheck?()
                        ProgressHUD.showSuccess(text: "修改成功")
                    case .failure:
                        ProgressHUD.showFailure()
                    }
                }
            case .failure:
                ProgressHUD.showFailure()
            }
        }
    }
    
}
