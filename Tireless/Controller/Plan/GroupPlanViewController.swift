//
//  GroupPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import UIKit
import CoreMIDI

class GroupPlanViewController: UIViewController {
    
    @IBOutlet var groupPlanView: GroupPlanView!
    
    var joinGroup: JoinGroup?
    
    var plan: Plans?
    
    var joinUsers: [User]? {
        didSet {
            for index in 0..<(joinUsers?.count ?? 0) {
                if joinUsers?[index].userId == DemoUser.demoUser {
                    groupPlanView.joinButton.isEnabled = false
                    groupPlanView.joinButton.setTitle("已加入", for: .normal)
                    groupPlanView.leaveButton.isHidden = false
                    groupPlanView.joinUserImage.text = joinUsers?[index].name
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
        viewModel.fetchJoinUsers(uuid: joinGroup.uuid) { result in
            switch result {
            case .success(let joinUsers):
                self.joinUsers = joinUsers
            case .failure(let error):
                print(error)
            }
        }
        if joinGroup.createdUserId == DemoUser.demoUser {
            groupPlanView.joinButton.setTitle("開始計畫", for: .normal)
            groupPlanView.leaveButton.isHidden = false
            groupPlanView.leaveButton.setTitle("放棄計畫", for: .normal)
        }
    }
    
    func setupLayout() {
        guard let joinGroup = joinGroup,
              let plan = plan else { return }
        groupPlanView.setupLayout(joinGroup: joinGroup, plan: plan)
    }
    
    func isBackButtonTap() {
        groupPlanView?.isBackButtonTap = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func isJoinButtonTap() {
        guard let joinGroup = joinGroup else { return }
        groupPlanView.isJoinButtonTap = { [weak self] in
            if joinGroup.createdUserId != DemoUser.demoUser {
                self?.viewModel.joinGroup(uuid: joinGroup.uuid) {
                    self?.dismiss(animated: true)
                } failure: { error in
                    print(error)
                }
            } else {
                var joinUsersId = [String]()
                self?.joinUsers?.forEach({joinUsersId.append($0.userId)})
                self?.viewModel.getGroupPlan(name: joinGroup.planName,
                                             times: joinGroup.planTimes,
                                             days: joinGroup.planDays,
                                             joinUserId: joinUsersId,
                                             uuid: joinGroup.uuid)
                self?.viewModel.startJoinGroup(uuid: joinGroup.uuid, completion: { result in
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
            if joinGroup.createdUserId == DemoUser.demoUser {
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
                self?.viewModel.leaveJoinGroup(uuid: joinGroup.uuid, userId: DemoUser.demoUser, completion: { result in
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
