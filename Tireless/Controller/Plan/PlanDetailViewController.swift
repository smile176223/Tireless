//
//  PlanDetailViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import UIKit

class PlanDetailViewController: UIViewController {
    
    @IBOutlet var planDetailView: PlanDetailView!
    
    var plan: Plans?
    
    let viewModel = PlanDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isBackButtonTap()
        isCreateButtonTap()
        setupLayout()
    }
    
    func setupLayout() {
        guard let plan = plan else {
            return
        }
        planDetailView.setupLayout(plan: plan)
    }
    
    func isBackButtonTap() {
        planDetailView?.isBackButtonTap = {
            self.dismiss(animated: true)
        }
    }
    
    func isCreateButtonTap() {
        guard let plan = plan else {
            return
        }
        planDetailView.isCreateButtonTap = { days, times in
            self.viewModel.getPlanData(name: plan.planName,
                                  times: times,
                                  days: days,
                                  createdTime: Date().millisecondsSince1970,
                                  planGroup: false)
            self.viewModel.createPlan(
                success: {
                    self.dismiss(animated: true)
                }, failure: { error in
                    print(error)
                })
        }
    }
}