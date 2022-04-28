//
//  ProfileViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, SectionItem>
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>
    
    private var dataSource: DataSource?
    
    let viewModel = ProfileViewModel()
    
    var userInfo: [User]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var friendsList: [User]? {
        didSet {
            dataSource?.apply(snapshot(), animatingDifferences: false)
        }
    }
    
    enum Section: Hashable {
        case user
    }
    
    enum SectionItem: Hashable {
        case friends(User)
    }
    
//    enum SectionItem: Hashable {
//        case friends(FriendsViewModel)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .themeBG
        
        configureCollectionView()
        configureDataSource()
        configureDataSourceProvider()
        configureDataSourceSnapshot()
        
        viewModel.userInfo.bind { [weak self] user in
            self?.userInfo = user
        }
        
        viewModel.friends.bind { [weak self] friends in
            self?.friendsList = friends
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        viewModel.fetchUser(userId: AuthManager.shared.currentUser)
        viewModel.fetchFriends(userId: AuthManager.shared.currentUser)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(UINib(nibName: "\(FriendListViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(FriendListViewCell.self)")
        
        collectionView.register(ProfileHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(ProfileHeaderView.self)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(80))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind:
                                                                    UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        header.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [header]
        
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 5, leading: 15, bottom: 5, trailing: 15)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, _) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(FriendListViewCell.self)",
                                                                for: indexPath) as? FriendListViewCell else {
                return UICollectionViewCell()
            }
            cell.isSetButtonTap = {
                self.setButtonAlert()
            }
            
            let cellViewModel = self.viewModel.friendViewModels.value[indexPath.row]
            cell.setup(viewModel: cellViewModel)
            
            return cell
        })
    }
    
    private func configureDataSourceProvider() {
        dataSource?.supplementaryViewProvider = { (collectionView, _, indexPath) in
            guard let headerView = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "\(ProfileHeaderView.self)",
                for: indexPath) as? ProfileHeaderView else { return UICollectionReusableView()}
        
            headerView.userImageView.loadImage(self.userInfo?.first?.picture)
            headerView.userNameLabel.text = self.userInfo?.first?.name
            
            headerView.isUserImageTap = {
                self.setUserAlert()
            }
            
            headerView.isSearchButtonTap = {
                self.searchFriendPresent()
            }
            
            return headerView
        }
    }
    
    private func configureDataSourceSnapshot() {
        dataSource?.apply(snapshot(), animatingDifferences: false)
    }
    
    private func snapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.user])
//        viewModel.friendViewModels.bind { friendsList in
//            snapshot.appendItems(friendsList.map({SectionItem.friends($0)}), toSection: .user)
//            self.dataSource?.apply(snapshot, animatingDifferences: false)
//        }
        if let friendsList = friendsList {
            snapshot.appendItems(friendsList.map({SectionItem.friends($0)}), toSection: .user)
        }
        return snapshot
    }
    
    private func setButtonAlert() {
        let controller = UIAlertController(title: "好友設定", message: nil, preferredStyle: .actionSheet)
        let names = ["刪除", "封鎖"]
        for name in names {
            let action = UIAlertAction(title: name, style: .destructive) { _ in
                // need to delete and ban user here
            }
            controller.addAction(action)
        }
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
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
}
