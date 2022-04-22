//
//  PlanDetailViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import UIKit

class PlanDetailViewController: UIViewController {
    
    @IBOutlet var planDetailView: PlanDetailView!
    
    let viewModel = PlanDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isBackButtonTap()
        isCreateButtonTap()
    }
    
    func isBackButtonTap() {
        planDetailView?.isBackButtonTap = {
            self.dismiss(animated: true)
        }
    }
    
    func isCreateButtonTap() {
        planDetailView.isCreateButtonTap = { days, times in
            self.viewModel.getPlanData(name: "Squat",
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
