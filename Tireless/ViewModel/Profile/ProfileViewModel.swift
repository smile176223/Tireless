//
//  ProfileViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

class ProfileViewModel {
    
    var userInfo = Box([User]())
    
    var friends = Box([Friends]())

    func fetchUser(userId: String) {
        UserManager.shared.fetchUser(userId: userId) { result in
            switch result {
            case .success(let user):
                self.userInfo.value = [user]
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchFriends(userId: String) {
        UserManager.shared.fetchFriends(userId: userId) { result in
            switch result {
            case .success(let friends):
                self.friends.value = friends
            case .failure(let error):
                print(error)
            }
        }
    }
}
