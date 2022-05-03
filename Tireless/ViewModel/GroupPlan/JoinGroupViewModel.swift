//
//  JoinGroupViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import Foundation

class JoinGroupViewModel {

    var plan: Plan = Plan(planName: "",
                          planTimes: "",
                          planDays: "",
                          createdTime: -1,
                          planGroup: true,
                          progress: 0.0,
                          finishTime: [],
                          uuid: "")
    
    let joinUsersViewModel = Box([JoinUsersViewModel]())

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
                ProgressHUD.showSuccess(text: "已加入!")
            case .failure(let error):
                failure(error)
                ProgressHUD.showFailure()
            }
        }
    }
    
    func fetchJoinUsers(uuid: String, completion: @escaping (Result<[User], Error>) -> Void) {
        JoinGroupManager.shared.fetchPlanJoinUser(uuid: uuid) { result in
            switch result {
            case .success(let users):
                completion(.success(users))
                self.setJoinUsers(users)
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
                ProgressHUD.showSuccess(text: "已放棄計畫!")
            case .failure(let error):
                completion(.failure(error))
                ProgressHUD.showFailure()
            }
        }
    }
    
    func leaveJoinGroup(uuid: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        JoinGroupManager.shared.leaveJoinGroup(uuid: uuid, userId: userId, completion: { result in
            switch result {
            case .success(let success):
                completion(.success(success))
                ProgressHUD.showSuccess(text: "已退出揪團!")
            case .failure(let error):
                completion(.failure(error))
                ProgressHUD.showFailure()
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
    
    func convertUsersToViewModels(from users: [User]) -> [JoinUsersViewModel] {
        var viewModels = [JoinUsersViewModel]()
        for user in users {
            let viewModel = JoinUsersViewModel(model: user)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setJoinUsers(_ users: [User]) {
        joinUsersViewModel.value = convertUsersToViewModels(from: users)
    }
}
