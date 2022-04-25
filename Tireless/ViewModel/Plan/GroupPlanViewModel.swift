//
//  GroupPlanViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import Foundation

class GroupPlanViewModel {
    
    func joinGroup(uuid: String, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        GroupPlanManager.shared.joinGroupPlan(uuid: uuid) { result in
            switch result {
            case .success:
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    func fetchJoinUsers(uuid: String, completion: @escaping (Result<[User], Error>) -> Void) {
        GroupPlanManager.shared.fetchPlanJoinUser(uuid: uuid) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
