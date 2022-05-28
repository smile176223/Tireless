//
//  InviteFriendViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//
import Foundation

class InviteFriendViewModel {
    
    let friendViewModels = Box([FriendsViewModel]())
    
    func getReceiveInvite() {
        FriendManager.shared.checkReceive { [weak self] result in
            switch result {
            case .success(let users):
                self?.setFriends(users)
            case .failure:
                ProgressHUD.showFailure()
            }
        }
    }
    
    func convertFriendsToViewModels(from friends: [User]) -> [FriendsViewModel] {
        var viewModels = [FriendsViewModel]()
        for friend in friends {
            let viewModel = FriendsViewModel(model: friend)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setFriends(_ friends: [User]) {
        friendViewModels.value = convertFriendsToViewModels(from: friends)
    }
    
}
