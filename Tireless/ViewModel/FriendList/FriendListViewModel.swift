//
//  FriendListViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/5/12.
//

import Foundation

class FriendListViewModel {
    
    var userInfo = Box([User]())
    
    var friends = Box([User]())
    
    let friendViewModels = Box([FriendsViewModel]())

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
    
    func fetchFriends(userId: String) {
        UserManager.shared.fetchFriends(userId: userId) { [weak self] result in
            switch result {
            case .success(let friends):
                self?.setFriends(friends)
                self?.friends.value = friends
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteFriend(userId: String) {
        FriendManager.shared.deleteFriend(userId: userId) { result in
            switch result {
            case .success(let text):
                print(text)
                ProgressHUD.showSuccess(text: "已刪除")
            case .failure(let error):
                print(error)
                ProgressHUD.showFailure()
            }
        }
    }
    
    func blockUser(blockId: String) {
        UserManager.shared.blockUser(blockId: blockId) { result in
            switch result {
            case .success(let text):
                ProgressHUD.showSuccess(text: "已封鎖")
                print(text)
            case .failure(let error):
                print(error)
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
