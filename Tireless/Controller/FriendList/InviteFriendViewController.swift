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
    
    var emptyView = UIImageView()
    
    let viewModel = InviteFriendViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "好友邀請"
        self.navigationController?.navigationBar.backgroundColor = .themeBG
        self.view.backgroundColor = .themeBG
        self.tableView.backgroundColor = .themeBG
        
        tableView.register(UINib(nibName: "\(InviteFriendViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(InviteFriendViewCell.self)")
        setEmptyView() 
        
        viewModel.getReceiveInvite()
        
        viewModel.friendViewModels.bind { [weak self] friends in
            self?.tableView.isHidden = friends.isEmpty
            self?.emptyView.isHidden = !friends.isEmpty
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setEmptyView() {
        emptyView.image = UIImage(named: "tireless_noinvite")
        emptyView.contentMode = .scaleAspectFit
        self.view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            emptyView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2)
        ])
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
        
        cell.agreeButtonTapped = {
            FriendManager.shared.addFriend(userId: cellViewModel.user.userId)
            ProgressHUD.showSuccess(text: "已加入")
        }
        
        cell.rejectButtonTapped = {
            FriendManager.shared.rejectInvite(userId: cellViewModel.user.userId)
            ProgressHUD.showSuccess(text: "已拒絕")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
