//
//  PlanDetailViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import UIKit

class PlanDetailViewController: UIViewController {
    
    @IBOutlet var planDetailView: PlanDetailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isBackButtonTap()
    }
    
    func isBackButtonTap() {
        planDetailView?.isBackButtonTap = {
            self.dismiss(animated: true)
        }
    }
}
