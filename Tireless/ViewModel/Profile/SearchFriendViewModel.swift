//
//  SearchFriendViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import Foundation

class SearchFriendViewModel {
    
    var userFriends = [String]()
    
    let friendViewModels = Box([FriendsViewModel]())
    
    func searchFriend(name: String) {
        FriendManager.shared.searchFriend(name: name) { [weak self] result in
            switch result {
            case .success(let users):
                self?.setFriends(users)
            case .failure(let error):
                print(error)
            }
        }
    }
    func getUserFriends() {
        UserManager.shared.fetchFriends(userId: AuthManager.shared.currentUser) { [weak self] result in
            switch result {
            case .success(let users):
                for user in users {
                    self?.userFriends.append(user.userId)
                }
            case .failure(let error):
                print(error)
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
