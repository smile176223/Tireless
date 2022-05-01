//
//  ProfileViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    let viewModel = ProfileViewModel()
    
    var friendsList: [User]?
    
    enum ProfileTab {
        case friends
        case historyPlan
    }
    
    var currentTab: ProfileTab = .friends {
        didSet {
            collectionView.collectionViewLayout = createLayout()
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .themeBG
        configureCollectionView()
        
        viewModel.friendViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.friends.bind { [weak self] friends in
            self?.friendsList = friends
        }
        
        viewModel.historyPlanViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        viewModel.fetchUser(userId: AuthManager.shared.currentUser)
        viewModel.fetchFriends(userId: AuthManager.shared.currentUser)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(UINib(nibName: "\(FriendListViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(FriendListViewCell.self)")
        
        collectionView.register(UINib(nibName: "\(PlanManageViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(PlanManageViewCell.self)")
        
        collectionView.register(UINib(nibName: "\(ProfileHeaderView.self)", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(ProfileHeaderView.self)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var itemHeight: CGFloat = 0
        switch currentTab {
        case .friends:
            itemHeight = 80
        case .historyPlan:
            itemHeight = 130
        }
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(itemHeight))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(220))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind:
                                                                    UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 5, leading: 15, bottom: 5, trailing: 15)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch currentTab {
        case .friends:
            return viewModel.friendViewModels.value.count
        case .historyPlan:
            return viewModel.historyPlanViewModels.value.count
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let friendsCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(FriendListViewCell.self)", for: indexPath) as? FriendListViewCell else {
            return UICollectionViewCell()
        }
        guard let historyCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(PlanManageViewCell.self)", for: indexPath) as? PlanManageViewCell else {
            return UICollectionViewCell()
        }
        
        switch currentTab {
        case .friends:
            let cellViewModel = self.viewModel.friendViewModels.value[indexPath.row]
            friendsCell.setup(viewModel: cellViewModel)
            
            friendsCell.isSetButtonTap = { [weak self] in
                self?.setButtonAlert(userId: cellViewModel.user.userId)
            }
            return friendsCell
        case .historyPlan:
            let cellViewModel = self.viewModel.historyPlanViewModels.value[indexPath.row]
            historyCell.planTitleLabel.text = cellViewModel.plan.planName
            
            return historyCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(ProfileHeaderView.self)",
            for: indexPath) as? ProfileHeaderView else {
            return UICollectionReusableView()
        }
        if AuthManager.shared.currentUserData?.picture == "" {
            headerView.userImageView.image = UIImage(named: "TirelessLogo")
        } else {
            headerView.userImageView.loadImage(AuthManager.shared.currentUserData?.picture)
        }
        headerView.userNameLabel.text = AuthManager.shared.currentUserData?.name

        headerView.isUserImageTap = { [weak self] in
            self?.setUserAlert()
        }

        headerView.isSearchButtonTap = { [weak self] in
            self?.searchFriendPresent()
        }

        headerView.isInviteTap = { [weak self] in
            self?.invitePresent()
        }
        
        headerView.isFriendsTab = { [weak self] in
            self?.currentTab = .friends
        }
        
        headerView.isHistoryTab = { [weak self] in
            self?.currentTab = .historyPlan
            self?.viewModel.fetchHistoryPlan()
        }
        
        return headerView
    }
}

extension ProfileViewController {
    private func setButtonAlert(userId: String) {
        let controller = UIAlertController(title: "好友設定", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
            self.viewModel.deleteFriend(userId: userId)
        }
        controller.addAction(deleteAction)
        let banAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            print("ban")
        }
        controller.addAction(banAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    private func setUserAlert() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "刪除帳號", style: .destructive) { _ in
            AuthManager.shared.deleteUser { [weak self] result in
                switch result {
                case .success(let string):
                    print(string)
                    self?.tabBarController?.selectedIndex = 0
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "錯誤",
                                                  message: "麻煩再次登入才可刪除帳號!",
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ok", style: .default) { _ in
                        if let authVC = UIStoryboard.auth.instantiateInitialViewController() {
                            self?.present(authVC, animated: true, completion: nil)
                        }
                    }
                    alert.addAction(okAction)
                    self?.present(alert, animated: true)
                }
            }
        }
        let logout = UIAlertAction(title: "登出", style: .default) { _ in
            AuthManager.shared.singOut { [weak self] result in
                switch result {
                case .success(let success):
                    self?.tabBarController?.selectedIndex = 0
                    print(success)
                case .failure(let error):
                    print(error)
                }
            }
        }
        controller.addAction(delete)
        controller.addAction(logout)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
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
    
    private func invitePresent() {
        guard let inviteVC = storyboard?.instantiateViewController(withIdentifier: "\(InviteFriendViewController.self)")
                as? InviteFriendViewController
        else {
            return
        }
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(inviteVC, animated: true)
    }
}
