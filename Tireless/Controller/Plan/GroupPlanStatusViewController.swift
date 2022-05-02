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
    
    let viewModel = GroupPlanStatusViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkStatus()
        
        self.navigationItem.title = "團體進度"
        
        self.view.backgroundColor = .themeBG
        
        tableView.register(UINib(nibName: "\(GroupPlanStatusViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(GroupPlanStatusViewCell.self)")
        
        viewModel.groupPlanStatusViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func checkStatus() {
        guard let plan = plan else {
            return
        }
        viewModel.fetchGroupPlanStatus(plan: plan)
    }
}

extension GroupPlanStatusViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.groupPlanStatusViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(GroupPlanStatusViewCell.self)", for: indexPath) as? GroupPlanStatusViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = viewModel.groupPlanStatusViewModels.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
}
