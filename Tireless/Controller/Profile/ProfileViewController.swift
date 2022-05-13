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
    
    var emptyView = UIImageView()
    
    let viewModel = ProfileViewModel()
    
    enum ProfileTab {
        case statistics
        case historyPlan
    }
    
    var currentTab: ProfileTab = .statistics {
        didSet {
            collectionView.collectionViewLayout = createLayout()
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setEmptyView()
        
        view.backgroundColor = .themeBG
        configureCollectionView()

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
        StatisticsManager.shared.fetchSquat { result in
            switch result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setEmptyView() {
        emptyView.image = UIImage(named: "tireless_nodata")
        emptyView.contentMode = .scaleAspectFit
        self.view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            emptyView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300),
            emptyView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            emptyView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(UINib(nibName: "\(StatisticsViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(StatisticsViewCell.self)")
        
        collectionView.register(UINib(nibName: "\(HistoryPlanViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(HistoryPlanViewCell.self)")
        
        collectionView.register(UINib(nibName: "\(ProfileHeaderView.self)", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(ProfileHeaderView.self)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var itemHeight: CGFloat = 0
        switch currentTab {
        case .statistics:
            itemHeight = 330
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
                                                heightDimension: .absolute(240))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind:
                                                                    UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 5, leading: 15, bottom: 5, trailing: 15)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func planReviewPresent(plan: Plan) {
        guard let reviewVC = UIStoryboard.plan.instantiateViewController(
            withIdentifier: "\(PlanReviewViewController.self)")
                as? PlanReviewViewController
        else {
            return
        }
        reviewVC.plan = plan
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentTab {
        case .statistics:
            return
        case .historyPlan:
            let cellViewModel = self.viewModel.historyPlanViewModels.value[indexPath.row]
            planReviewPresent(plan: cellViewModel.plan)
        }
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch currentTab {
        case .statistics:
            emptyView.isHidden = true
            return 1
        case .historyPlan:
            if viewModel.historyPlanViewModels.value.count == 0 {
                collectionView.isScrollEnabled = false
                emptyView.isHidden = false
            } else {
                collectionView.isScrollEnabled = true
                emptyView.isHidden = true
            }
            return viewModel.historyPlanViewModels.value.count
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let statisticsCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(StatisticsViewCell.self)", for: indexPath) as? StatisticsViewCell else {
            return UICollectionViewCell()
        }
        guard let historyCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(HistoryPlanViewCell.self)", for: indexPath) as? HistoryPlanViewCell else {
            return UICollectionViewCell()
        }
        
        switch currentTab {
        case .statistics:
//            let cellViewModel = self.viewModel.friendViewModels.value[indexPath.row]
//            friendsCell.setup(viewModel: cellViewModel)
//
//            friendsCell.isSetButtonTap = { [weak self] in
//                self?.setButtonAlert(userId: cellViewModel.user.userId)
//            }
            return statisticsCell
        case .historyPlan:
            let cellViewModel = self.viewModel.historyPlanViewModels.value[indexPath.row]
            historyCell.setup(viewModel: cellViewModel)
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
            headerView.userImageView.image = UIImage.placeHolder
        } else {
            headerView.userImageView.loadImage(AuthManager.shared.currentUserData?.picture)
        }
        headerView.userNameLabel.text = AuthManager.shared.currentUserData?.name

        headerView.isUserImageTap = { [weak self] in
            self?.setUserInfoAlert()
        }
        
        headerView.isCountTab = { [weak self] in
            self?.currentTab = .statistics
        }
        
        headerView.isHistoryTab = { [weak self] in
            self?.currentTab = .historyPlan
            self?.viewModel.fetchHistoryPlan()
        }
        
        headerView.isSetListButtonTab = { [weak self] in
            self?.userSetAlert()
        }
        
        headerView.isBellAlertButtonTap = { [weak self] in
            self?.notificationPresent()
        }
        
        headerView.isFriendsButtonTap = { [weak self] in
            self?.friendsListPresent()
        }
        
        return headerView
    }
}

extension ProfileViewController {
    private func userSetAlert() {
        let controller = UIAlertController(title: "設定", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "刪除帳號", style: .destructive) { _ in
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
        controller.addAction(deleteAction)
        let blockAction = UIAlertAction(title: "黑名單", style: .default) { _ in
            self.blockPresent()
        }
        controller.addAction(blockAction)
        let logoutAction = UIAlertAction(title: "登出", style: .default) { _ in
            AuthManager.shared.singOut { [weak self] result in
                switch result {
                case .success(let success):
                    ProgressHUD.showSuccess(text: "已登出")
                    self?.tabBarController?.selectedIndex = 0
                    print(success)
                case .failure(let error):
                    ProgressHUD.showFailure()
                    print(error)
                }
            }
        }
        controller.addAction(logoutAction)
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
    
    private func setUserInfoAlert() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let imageChange = UIAlertAction(title: "更換圖片", style: .default) { _ in
//            
//        }
        let nameChange = UIAlertAction(title: "更換姓名", style: .default) { _ in
            self.showSettingAlert()
        }
//        controller.addAction(imageChange)
        controller.addAction(nameChange)
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
    
    private func showSettingAlert() {
        let alertController = UIAlertController(title: "更名",
                                                message: "可以更改使用者姓名/暱稱",
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "姓名/暱稱"
            textField.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "修改", style: .destructive) { _ in
            let name = alertController.textFields?[0].text
            guard let name = name else {
                return
            }
            ProfileManager.shared.changeUserName(name: name) { result in
                switch result {
                case .success(let text):
                    ProgressHUD.showSuccess(text: "修改成功")
                    AuthManager.shared.getCurrentUser { result in
                        switch result {
                        case .success(let bool):
                            print(bool)
                            self.collectionView.reloadData()
                        case .failure(let error):
                            print(error)
                        }
                    }
                    print(text)
                case .failure(let error):
                    ProgressHUD.showFailure()
                    print(error)
                }
            }
            alertController.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        // iPad specific code
        alertController.popoverPresentationController?.sourceView = self.view
        let xOrigin = self.view.bounds.width / 2
        let popoverRect = CGRect(x: xOrigin, y: self.view.bounds.height, width: 1, height: 1)
        alertController.popoverPresentationController?.sourceRect = popoverRect
        alertController.popoverPresentationController?.permittedArrowDirections = .down
        
        self.present(alertController, animated: true)
    }
    
    private func blockPresent() {
        guard let blockVC = storyboard?.instantiateViewController(withIdentifier: "\(BlockListViewController.self)")
                as? BlockListViewController
        else {
            return
        }
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(blockVC, animated: true)
    }
    
    private func notificationPresent() {
        guard let notifyVC = UIStoryboard.profile.instantiateViewController(
            withIdentifier: "\(NotificationViewController.self)")
                as? NotificationViewController
        else {
            return
        }
        notifyVC.modalPresentationStyle = .overCurrentContext
        notifyVC.modalTransitionStyle = .crossDissolve
        present(notifyVC, animated: true)
    }
    
    private func friendsListPresent() {
        guard let friendsVC = UIStoryboard.profile.instantiateViewController(
            withIdentifier: "\(FriendsListViewController.self)")
                as? FriendsListViewController
        else {
            return
        }
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
}
