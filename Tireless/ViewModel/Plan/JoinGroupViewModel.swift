//
//  JoinGroupViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import Foundation

class JoinGroupViewModel {
    
    var groupPlan: GroupPlan = GroupPlan(planName: "",
                                         planTimes: "",
                                         planDays: "",
                                         planGroup: true,
                                         createdTime: -1,
                                         createdUserId: AuthManager.shared.currentUser,
                                         joinUserId: [""],
                                         uuid: "")
    
    var plan: Plan = Plan(planName: "",
                          planTimes: "",
                          planDays: "",
                          createdTime: -1,
                          planGroup: true,
                          progress: 0.0,
                          finishTime: [],
                          uuid: "")
    
    func getGroupPlan(name: String, times: String, days: String, joinUserId: [String], uuid: String) {
        self.groupPlan.planName = name
        self.groupPlan.planTimes = times
        self.groupPlan.planDays = days
        self.groupPlan.createdTime = Date().millisecondsSince1970
        self.groupPlan.joinUserId = joinUserId
        self.groupPlan.uuid = uuid
    }
    
    func setGroupPlan(name: String, times: String, days: String, uuid: String) {
        self.plan.planName = name
        self.plan.planTimes = times
        self.plan.planDays = days
        self.plan.createdTime = Date().millisecondsSince1970
        self.plan.uuid = uuid
    }
    
    func joinGroup(uuid: String, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        JoinGroupManager.shared.joinGroupPlan(uuid: uuid) { result in
            switch result {
            case .success:
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    func fetchJoinUsers(uuid: String, completion: @escaping (Result<[User], Error>) -> Void) {
        JoinGroupManager.shared.fetchPlanJoinUser(uuid: uuid) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteJoinGroup(uuid: String, completion: @escaping (Result<String, Error>) -> Void) {
        JoinGroupManager.shared.deleteJoinGroup(uuid: uuid) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func leaveJoinGroup(uuid: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        JoinGroupManager.shared.leaveJoinGroup(uuid: uuid, userId: userId, completion: { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
//    func startJoinGroup(uuid: String, completion: @escaping (Result<String, Error>) -> Void) {
//        JoinGroupManager.shared.startJoinGroup(uuid: uuid, groupPlan: groupPlan) { result in
//            switch result {
//            case .success(let success):
//                completion(.success(success))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    func createGroupPlan(uuid: String, joinUsers: [String], completion: @escaping (Result<String, Error>) -> Void) {
        JoinGroupManager.shared.createGroupPlan(uuid: uuid, plan: plan, joinUsers: joinUsers) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
