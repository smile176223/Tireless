//
//  InviteFriendViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import UIKit

class InviteFriendViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    let viewModel = InviteFriendViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = .themeBG
        self.view.backgroundColor = .themeBG
        self.tableView.backgroundColor = .themeBG
        
        tableView.register(UINib(nibName: "\(InviteFriendViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(InviteFriendViewCell.self)")
        
        viewModel.getReceiveInvite()
        
        viewModel.friendViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
    }
}

extension InviteFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.friendViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(InviteFriendViewCell.self)", for: indexPath) as? InviteFriendViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = self.viewModel.friendViewModels.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        
        cell.isAgreeButtonTap = {
            FriendManager.shared.addFriend(userId: cellViewModel.user.userId)
            ProgressHUD.showSuccess(text: "已加入!")
        }
        
        cell.isRejectButtonTap = {
            FriendManager.shared.rejectInvite(userId: cellViewModel.user.userId)
            ProgressHUD.showSuccess(text: "已拒絕!")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
