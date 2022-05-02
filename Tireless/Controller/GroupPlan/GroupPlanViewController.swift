//
//  GroupPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import UIKit

class GroupPlanViewController: UIViewController {
    
    @IBOutlet var groupPlanView: GroupPlanView!
    
    var joinGroup: JoinGroup?
    
    var joinUsers: [User]? {
        didSet {
            for index in 0..<(joinUsers?.count ?? 0) {
                groupPlanView.joinUserImage.text = joinUsers?[index].name
                if joinUsers?[index].userId == AuthManager.shared.currentUser {
                    groupPlanView.joinButton.isEnabled = false
                    groupPlanView.joinButton.setTitle("已加入", for: .normal)
                    groupPlanView.leaveButton.isHidden = false
                }
            }
        }
    }
    
    let viewModel = JoinGroupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        isBackButtonTap()
        isJoinButtonTap()
        isLeaveButtonTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let joinGroup = joinGroup else { return }
        viewModel.fetchJoinUsers(uuid: joinGroup.uuid) { [weak self] result in
            switch result {
            case .success(let joinUsers):
                self?.joinUsers = joinUsers
            case .failure(let error):
                print(error)
            }
        }
        if joinGroup.createdUserId == AuthManager.shared.currentUser {
            groupPlanView.joinButton.setTitle("開始計畫", for: .normal)
            groupPlanView.leaveButton.isHidden = false
            groupPlanView.leaveButton.setTitle("放棄計畫", for: .normal)
        }
    }
    
    func setupLayout() {
        guard let joinGroup = joinGroup else { return }
        groupPlanView.setupLayout(joinGroup: joinGroup)
    }
    
    func isBackButtonTap() {
        groupPlanView?.isBackButtonTap = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func isJoinButtonTap() {
        guard let joinGroup = joinGroup else { return }
        groupPlanView.isJoinButtonTap = { [weak self] in
            if joinGroup.createdUserId != AuthManager.shared.currentUser {
                self?.viewModel.joinGroup(uuid: joinGroup.uuid) {
                    self?.dismiss(animated: true)
                } failure: { error in
                    print(error)
                }
            } else {
                var joinUsersId = [AuthManager.shared.currentUser]
                self?.joinUsers?.forEach({joinUsersId.append($0.userId)})
                self?.viewModel.setGroupPlan(name: joinGroup.planName,
                                             times: joinGroup.planTimes,
                                             days: joinGroup.planDays,
                                             uuid: joinGroup.uuid)
                self?.viewModel.createGroupPlan(uuid: joinGroup.uuid, joinUsers: joinUsersId, completion: { result in
                    switch result {
                    case .success(let string):
                        print(string)
                    case .failure(let error):
                        print(error)
                    }
                })
                self?.dismiss(animated: true)
            }
            
        }
    }
    
    func isLeaveButtonTap() {
        guard let joinGroup = joinGroup else { return }
        groupPlanView.isLeaveButtonTap = { [weak self] in
            if joinGroup.createdUserId == AuthManager.shared.currentUser {
                self?.viewModel.deleteJoinGroup(uuid: joinGroup.uuid) { result in
                    switch result {
                    case .success(let string):
                        print(string)
                        self?.dismiss(animated: true)
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                self?.viewModel.leaveJoinGroup(uuid: joinGroup.uuid,
                                               userId: AuthManager.shared.currentUser,
                                               completion: { result in
                    switch result {
                    case .success(let string):
                        print(string)
                        self?.dismiss(animated: true)
                    case .failure(let error):
                        print(error)
                    }
                })
            }
        }
    }
}