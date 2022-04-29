//
//  GroupPlanStatusViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/29.
//

import UIKit

class GroupPlanStatusViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = .themeBG
        }
    }
    
    var plan: Plan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkStatus()
    }
    
    private func checkStatus() {
        guard let plan = plan else {
            return
        }
        PlanManager.shared.checkGroupUsersStatus(plan: plan)
    }
}

extension GroupPlanStatusViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
}
