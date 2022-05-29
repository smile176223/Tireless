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
    
    let joinUsers = Box([User]())
    
    var joinGroup: JoinGroup
    
    init(joinGroup: JoinGroup) {
        self.joinGroup = joinGroup
    }
    
    func checkGroupOwner() -> Bool {
        if joinGroup.createdUserId == AuthManager.shared.currentUser {
            return true
        }
        return false
    }

    func setGroupPlan(name: String, times: String, days: String, uuid: String) {
        self.plan.planName = name
        self.plan.planTimes = times
        self.plan.planDays = days
        self.plan.createdTime = Date().millisecondsSince1970
        self.plan.uuid = uuid
    }
    
    func joinGroup(success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        JoinGroupManager.shared.joinGroupPlan(uuid: joinGroup.uuid) { result in
            switch result {
            case .success:
                success()
                ProgressHUD.showSuccess(text: "已加入")
            case .failure:
                ProgressHUD.showFailure()
            }
        }
    }
    func fetchJoinUsers() {
        JoinGroupManager.shared.fetchPlanJoinUser(uuid: joinGroup.uuid) { result in
            switch result {
            case .success(let users):
                self.setJoinUsers(users)
                self.joinUsers.value = users
            case .failure:
                ProgressHUD.showFailure()
            }
        }
    }
    
    func deleteJoinGroup(uuid: String, completion: @escaping (Result<String, Error>) -> Void) {
        JoinGroupManager.shared.deleteJoinGroup(uuid: uuid) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
                ProgressHUD.showSuccess(text: "已放棄計畫")
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
                ProgressHUD.showSuccess(text: "已退出揪團")
            case .failure(let error):
                completion(.failure(error))
                ProgressHUD.showFailure()
            }
        })
    }
    
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
    
    func startGroup(successJoin: (() -> Void)?, createDone: (() -> Void)?) {
        if !checkGroupOwner() {
            joinGroup {
                successJoin?()
            } failure: { _ in
                ProgressHUD.showFailure()
            }
        } else {
            var joinUsersId = [AuthManager.shared.currentUser]
            joinUsers.value.forEach {joinUsersId.append($0.userId)}
            setGroupPlan(name: joinGroup.planName,
                         times: joinGroup.planTimes,
                         days: joinGroup.planDays,
                         uuid: joinGroup.uuid)
            createGroupPlan(uuid: joinGroup.uuid,
                            joinUsers: joinUsersId) { result in
                switch result {
                case .success(let string):
                    print(string)
                case .failure:
                    ProgressHUD.showFailure()
                }
                createDone?()
            }
        }
    }
    
    func stopGroup(stopDone: (() -> Void)?) {
        if checkGroupOwner() {
            deleteJoinGroup(uuid: joinGroup.uuid) { result in
                switch result {
                case .success:
                    stopDone?()
                case .failure:
                    ProgressHUD.showFailure()
                }
            }
        } else {
            leaveJoinGroup(uuid: joinGroup.uuid,
                           userId: AuthManager.shared.currentUser) { result in
                switch result {
                case .success:
                    stopDone?()
                case .failure:
                    ProgressHUD.showFailure()
                }
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
