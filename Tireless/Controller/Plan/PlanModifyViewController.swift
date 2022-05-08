//
//  PlanModifyViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/8.
//

import UIKit

class PlanModifyViewController: UIViewController {
    
    @IBOutlet weak var planAlertView: UIView!
    
    @IBOutlet weak var planImageView: UIImageView!
    
    @IBOutlet weak var planDetailLabel: UILabel!
    
    @IBOutlet weak var planCounter: CounterView!
    
    @IBOutlet weak var planCheckButton: UIButton!
    
    var plan: Plan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlan()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupLayout() {
        planImageView.layer.cornerRadius = planImageView.frame.height / 2
        planCheckButton.layer.cornerRadius = 15
        planAlertView.layer.cornerRadius = 25
    }
    
    private func setupPlan() {
        guard let plan = plan else {
            return
        }
        planImageView.image = UIImage(named: plan.planName)
        if plan.planName == PlanExercise.plank.rawValue {
            planDetailLabel.text = "每天\(plan.planTimes)秒，持續\(plan.planDays)天"
        } else {
            planDetailLabel.text = "每天\(plan.planTimes)次，持續\(plan.planDays)天"
        }
    }
    
    @IBAction func planCheckButtonTap(_ sender: UIButton) {
        guard let plan = plan else {
            return
        }
        PlanManager.shared.modifyPlan(planUid: plan.uuid,
                                      times: planCounter.getInputField()) { result in
            switch result {
            case .success(let text):
                self.dismiss(animated: true)
                ProgressHUD.showSuccess(text: "修改計畫成功")
                print(text)
            case .failure(let error):
                ProgressHUD.showFailure()
                print(error)
            }
        }
    }
}
