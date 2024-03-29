//
//  FriendsListViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/12.
//

import UIKit

class FriendsListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    let viewModel = FriendListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = .themeBG
        
        self.navigationController?.navigationBar.backgroundColor = .themeBG
        
        self.view.backgroundColor = .themeBG
        
        self.tableView.backgroundColor = .themeBG
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.fill.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(invitePresent)
        )
        
        tableView.register(UINib(nibName: "\(FriendListHeaderView.self)", bundle: nil),
                                 forHeaderFooterViewReuseIdentifier: "\(FriendListHeaderView.self)")
        
        tableView.register(UINib(nibName: "\(FriendListViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(FriendListViewCell.self)")
        
        viewModel.friendViewModels.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = .leastNormalMagnitude
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFriends()
    }
    
    private func searchFriendPresent() {
        guard let searchVC = storyboard?.instantiateViewController(withIdentifier: "\(SearchFriendViewController.self)")
                as? SearchFriendViewController
        else {
            return
        }
        searchVC.viewModel = SearchFriendViewModel(friendsList: self.viewModel.friends.value)
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func invitePresent() {
        guard let inviteVC = storyboard?.instantiateViewController(withIdentifier: "\(InviteFriendViewController.self)")
                as? InviteFriendViewController
        else {
            return
        }
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(inviteVC, animated: true)
    }
}

extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.friendViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(FriendListViewCell.self)", for: indexPath) as? FriendListViewCell else {
            return UITableViewCell()
        }
        let cellViewModel = self.viewModel.friendViewModels.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        
        cell.setButtonTapped = { [weak self] in
            self?.setButtonAlert(userId: cellViewModel.user.userId)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "\(FriendListHeaderView.self)")
                as? FriendListHeaderView else {
            return UIView()
        }
        header.findButtonTapped = { [weak self] in
            self?.searchFriendPresent()
        }
        
        header.receiveButtonTapped = { [weak self] in
            self?.invitePresent()
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
}

extension FriendsListViewController {
    private func setButtonAlert(userId: String) {
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
            self.viewModel.deleteFriend(userId: userId)
        }
        let banAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            self.viewModel.blockUser(blockId: userId)
        }
        let cancel = UIAlertAction.cancelAction
        let actions = [deleteAction, banAction, cancel]
        presentAlert(withTitle: "好友設定", style: .actionSheet, actions: actions)
    }
}
