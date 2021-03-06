//
//  PlanDetailViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import UIKit

class PlanDetailViewController: UIViewController {
    
    @IBOutlet private var planDetailView: PlanDetailView!
    
    var viewModel: PlanDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isBackButtonTap()
        
        isCreateButtonTap()
        
        setupLayout()
        
        setupBind()
    }
    
    private func setupLayout() {
        guard let viewModel = viewModel else {
            return
        }
        planDetailView.setupLayout(plan: viewModel.defaultPlans)
    }
    
    private func isBackButtonTap() {
        planDetailView?.backButtonTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func setupBind() {
        viewModel?.isCreatePlan.bind { [weak self] isCreate in
            guard let isCreate = isCreate else {
                return
            }
            if isCreate {
                self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                if let tabBarController = self?.presentingViewController as? UITabBarController {
                    tabBarController.selectedIndex = 1
                }
            }
        }
        viewModel?.isUserLogin.bind { [weak self] isUserLogin in
            guard let isUserLogin = isUserLogin else {
                return
            }
            if isUserLogin {
                self?.authPresent()
            }
        }
    }
    
    private func isCreateButtonTap() {
        planDetailView.createButtonTapped = { [weak self] days, times in
            self?.viewModel?.createPlan(times: times, days: days)
        }
    }
    
    private func authPresent() {
        if let authVC = UIStoryboard.auth.instantiateInitialViewController() {
            present(authVC, animated: true, completion: nil)
        }
    }
}
