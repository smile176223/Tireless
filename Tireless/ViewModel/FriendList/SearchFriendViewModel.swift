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
    
    var checkList = [AuthManager.shared.currentUser]
    
    var friendsList: [User]
    
    init(friendsList: [User]) {
        self.friendsList = friendsList
    }
    
    func checkFriendsList() {
        for friend in friendsList {
            self.checkList.append(friend.userId)
        }
    }
    
    func checkSearch(userId: String) -> Bool {
        return checkList.contains(userId)
    }
    
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
    
    func inviteFriend(userId: String) {
        FriendManager.shared.inviteFriend(userId: userId)
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
