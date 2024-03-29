//
//  ProfileViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    private var emptyView = UIImageView()
    
    let viewModel = ProfileViewModel()
    
    private enum ProfileTab {
        case statistics
        case historyPlan
    }
    
    private var currentTab: ProfileTab = .statistics {
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
            self?.collectionView.reloadData()
        }
        
        viewModel.statisticsViewModels.bind { [weak self] _ in
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        viewModel.fetchUser(userId: AuthManager.shared.currentUser)
        viewModel.fetchStatistics(with: PlanExercise.squat)
        viewModel.fetchStatistics(with: PlanExercise.plank)
        viewModel.fetchStatistics(with: PlanExercise.pushup)
        viewModel.fetchDays()
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
        var groupInset: CGFloat = 0
        switch currentTab {
        case .statistics:
            itemHeight = 350
            groupInset = 15
        case .historyPlan:
            itemHeight = 130
            groupInset = 0
        }
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(itemHeight))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        group.contentInsets = .init(top: 0, leading: groupInset, bottom: 0, trailing: groupInset)
        
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
        reviewVC.viewModel = PlanReviewViewModel(plan: plan)
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
            let cellViewModel = self.viewModel.statisticsViewModels.value
            statisticsCell.setup(viewModel: cellViewModel)
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

        headerView.userImageTapped = { [weak self] in
            self?.setUserInfoAlert()
        }
        
        headerView.countTapped = { [weak self] in
            self?.currentTab = .statistics
        }
        
        headerView.historyTapped = { [weak self] in
            self?.currentTab = .historyPlan
            self?.viewModel.fetchHistoryPlan()
        }
        
        headerView.setListButtonTapped = { [weak self] in
            self?.setUserSettingAlert()
        }
        
        headerView.bellAlertButtonTapped = { [weak self] in
            self?.notificationPresent()
        }
        
        headerView.friendsButtonTapped = { [weak self] in
            self?.friendsListPresent()
        }
        
        return headerView
    }
}

extension ProfileViewController {
    private func setUserSettingAlert() {
        let delete = UIAlertAction(title: "刪除帳號", style: .destructive) { _ in
            let okAction = UIAlertAction(title: "確認", style: .destructive) { _ in
                self.deleteAccount()
            }
            let cancel = UIAlertAction.cancelAction
            let actions = [okAction, cancel]
            self.presentAlert(withTitle: "確認是否刪除帳號", message: "刪除後資料無法回復，請謹慎使用!", style: .alert, actions: actions)
        }
        let block = UIAlertAction(title: "黑名單", style: .default) { _ in
            self.blockPresent()
        }
        let logout = UIAlertAction(title: "登出", style: .default) { [weak self] _ in
            self?.viewModel.signOut {
                self?.tabBarController?.selectedIndex = 0
            }
        }
        let cancel = UIAlertAction.cancelAction
        let actions = [delete, block, logout, cancel]
        presentAlert(withTitle: "設定", style: .actionSheet, actions: actions)
    }
    
    private func deleteAccount() {
        viewModel.deleteAccount { [weak self] result in
            switch result {
            case .success(let string):
                self?.tabBarController?.selectedIndex = 0
                print(string)
            case .failure(let error):
                print(error)
                let okAction = UIAlertAction(title: "ok", style: .default) { _ in
                    if let authVC = UIStoryboard.auth.instantiateInitialViewController() {
                        self?.present(authVC, animated: true, completion: nil)
                    }
                }
                
                let actions = [okAction]
                self?.presentAlert(withTitle: "錯誤", message: "麻煩再次登入才可刪除帳號!", style: .alert, actions: actions)
            }
        }
    }
    private func setUserInfoAlert() {
        let imageChange = UIAlertAction(title: "更換圖片", style: .default) { _ in
            self.selectImage()
        }
        let nameChange = UIAlertAction(title: "更換姓名", style: .default) { _ in
            self.editProfilePresent()
        }
        let cancel = UIAlertAction.cancelAction
        let actions = [imageChange, nameChange, cancel]
        presentAlert(style: .actionSheet, actions: actions)
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
    
    private func editProfilePresent() {
        guard let editVC = UIStoryboard.profile.instantiateViewController(
            withIdentifier: "\(EditProfileViewController.self)")
                as? EditProfileViewController
        else {
            return
        }
        editVC.checkbuttonTapped = { [weak self] in
            self?.collectionView.reloadData()
        }
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.modalTransitionStyle = .crossDissolve
        present(editVC, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
                               info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image: UIImage = info[.editedImage] as? UIImage else { return }
        guard let imageData: Data = image.jpegData(compressionQuality: 0.5) else { return }
        viewModel.uploadPicture(imageData: imageData) { [weak self] in
            self?.collectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
}
