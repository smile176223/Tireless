//
//  FriendsListViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/12.
//

import UIKit

class FriendsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var friendsList: [User]?
    
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
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.friends.bind { [weak self] friends in
            self?.friendsList = friends
        }
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = .leastNormalMagnitude
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFriends(userId: AuthManager.shared.currentUser)
    }
    
    private func searchFriendPresent() {
        guard let searchVC = storyboard?.instantiateViewController(withIdentifier: "\(SearchFriendViewController.self)")
                as? SearchFriendViewController
        else {
            return
        }
        searchVC.friendsList = self.friendsList
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
        
        cell.isSetButtonTap = { [weak self] in
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
        header.isFindButtonTap = { [weak self] in
            self?.searchFriendPresent()
        }
        
        header.isReceiveButtonTap = { [weak self] in
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
        let controller = UIAlertController(title: "好友設定", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
            self.viewModel.deleteFriend(userId: userId)
        }
        controller.addAction(deleteAction)
        let banAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            self.viewModel.blockUser(blockId: userId)
        }
        controller.addAction(banAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        // iPad specific code
        controller.popoverPresentationController?.sourceView = self.view
        let xOrigin = self.view.bounds.width / 2
        let popoverRect = CGRect(x: xOrigin, y: self.view.bounds.height, width: 1, height: 1)
        controller.popoverPresentationController?.sourceRect = popoverRect
        controller.popoverPresentationController?.permittedArrowDirections = .down
        
        present(controller, animated: true, completion: nil)
    }
}
