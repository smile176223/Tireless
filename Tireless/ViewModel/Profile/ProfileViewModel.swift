//
//  ProfileViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import Foundation

class ProfileViewModel {
    
    var userInfo = Box([User]())
    
    var plan: [Plan]?
    
    var historyPlan: [Plan]?
    
    let historyPlanViewModels = Box([HistoryPlanViewModel]())
    
    var statisticsViewModels = Box(Statistics(squatCount: 0,
                                              pushupCount: 0,
                                              plankCount: 0,
                                              totalComplete: 0))

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
    
    func fetchPlan() {
        PlanManager.shared.fetchPlan(userId: AuthManager.shared.currentUser) { [weak self] result in
            switch result {
            case .success(let plans):
                self?.plan = plans
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchHistoryPlan() {
        PlanManager.shared.fetchHistoryPlan(userId: AuthManager.shared.currentUser) { [weak self] result in
            switch result {
            case .success(let plans):
                self?.setHistoryPlan(plans)
                self?.historyPlan = plans
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchStatistics(with planExercise: PlanExercise) {
        StatisticsManager.shared.fetchStatistics(with: planExercise.rawValue) { result in
            switch result {
            case .success(let count):
                switch planExercise {
                case .squat:
                    self.statisticsViewModels.value.squatCount = count
                case .pushup:
                    self.statisticsViewModels.value.pushupCount = count
                case .plank:
                    self.statisticsViewModels.value.plankCount = count
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchDays() {
        StatisticsManager.shared.fetchDays { result in
            switch result {
            case .success(let count):
                self.statisticsViewModels.value.totalComplete = count
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func convertPlansToViewModels(from plans: [Plan]) -> [HistoryPlanViewModel] {
        var viewModels = [HistoryPlanViewModel]()
        for plan in plans {
            let viewModel = HistoryPlanViewModel(model: plan)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setHistoryPlan(_ plans: [Plan]) {
        historyPlanViewModels.value = convertPlansToViewModels(from: plans)
    }
    
    func signOut(success: (() -> Void)?) {
        AuthManager.shared.singOut { result in
            switch result {
            case .success(let text):
                ProgressHUD.showSuccess(text: text)
                success?()
            case .failure(let error):
                print(error)
                ProgressHUD.showFailure()
            }
        }
    }
    
    func deleteAccount(completion: @escaping (Result<String, Error>) -> Void) {
        AuthManager.shared.deleteUser { result in
            switch result {
            case .success(let string):
                ProgressHUD.showSuccess(text: "已刪除")
                completion(.success(string))
            case .failure(let error):
                ProgressHUD.showFailure()
                completion(.failure(error))
            }
        }
    }
    
    func uploadPicture(imageData: Data, success: (() -> Void)?) {
        ProgressHUD.show()
        ShareManager.shared.uploadPicture(imageData: imageData) { result in
            switch result {
            case .success(let url):
                print(url)
                AuthManager.shared.getCurrentUser { result in
                    switch result {
                    case .success(let bool):
                        print(bool)
                        ProgressHUD.showSuccess(text: "成功更換")
                        success?()
                    case .failure(let error):
                        ProgressHUD.showFailure(text: "讀取失敗")
                        print(error)
                    }
                }
            case .failure(let error):
                ProgressHUD.showFailure(text: "更換失敗")
                print(error)
            }
        }
    }
}
