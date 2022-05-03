//
//  FriendsViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import Foundation

class FriendsViewModel {
    var user: User
    
    init(model user: User) {
        self.user = user
    }
}

extension FriendsViewModel: Hashable {
    static func == (lhs: FriendsViewModel, rhs: FriendsViewModel) -> Bool {
        return lhs.user.userId == rhs.user.userId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(user.userId)
    }
}
