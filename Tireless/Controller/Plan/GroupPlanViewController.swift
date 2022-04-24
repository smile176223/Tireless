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
    
    var groupPlan: GroupPlans?
    
    var plan: Plans?
    
    var joinUsers: [UserId]? {
        didSet {
            for index in 0..<(joinUsers?.count ?? 0) {
                if joinUsers?[index].userId == DemoUser.demoUser {
                    groupPlanView.joinButton.isEnabled = false
                    groupPlanView.joinButton.setTitle("已加入", for: .normal)
                    groupPlanView.joinUserImage.text = joinUsers?[index].userId 
                }
            }
        }
    }
    
    let viewModel = GroupPlanViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isBackButtonTap()
        setupLayout()
        isJoinButtonTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let groupPlan = groupPlan else { return }
        viewModel.fetchJoinUsers(uuid: groupPlan.uuid) { result in
            switch result {
            case .success(let joinUsers):
                self.joinUsers = joinUsers
                print(joinUsers)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupLayout() {
        guard let groupPlan = groupPlan,
              let plan = plan else { return }
        groupPlanView.setupLayout(groupPlan: groupPlan, plan: plan, userId: joinUsers ?? [UserId(userId: "")])
    }
    
    func isBackButtonTap() {
        groupPlanView?.isBackButtonTap = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func isJoinButtonTap() {
        guard let groupPlan = groupPlan else { return }
        groupPlanView.isJoinButtonTap = { [weak self] in
            self?.viewModel.joinGroup(uuid: groupPlan.uuid) {
                self?.dismiss(animated: true)
            } failure: { error in
                print(error)
            }

        }
    }
}
