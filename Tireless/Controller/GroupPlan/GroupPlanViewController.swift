//
//  GroupPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import UIKit

class GroupPlanViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var groupPlanImageView: UIImageView!
    
    @IBOutlet weak var planLeaveButton: UIButton!
    
    @IBOutlet weak var planJoinButton: UIButton!
    
    var joinGroup: JoinGroup?
    
    var joinUsers: [User]? {
        didSet {
            for index in 0..<(joinUsers?.count ?? 0) {
                if joinUsers?[index].userId == AuthManager.shared.currentUser {
                    planJoinButton.isEnabled = false
                    planJoinButton.setTitle("已加入", for: .normal)
                    planLeaveButton.isHidden = false
                }
            }
        }
    }
    
    let viewModel = JoinGroupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureCollectionView()
        
        viewModel.joinUsersViewModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let joinGroup = joinGroup else { return }
        viewModel.fetchJoinUsers(uuid: joinGroup.uuid) { [weak self] result in
            switch result {
            case .success(let joinUsers):
                self?.joinUsers = joinUsers
            case .failure(let error):
                print(error)
            }
        }
        if joinGroup.createdUserId == AuthManager.shared.currentUser {
            planJoinButton.setTitle("開始計畫", for: .normal)
            planLeaveButton.isHidden = false
            planLeaveButton.setTitle("放棄計畫", for: .normal)
        }
    }
    
    @IBAction func backButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBAction func joinButtonTap(_ sender: UIButton) {
        guard let joinGroup = joinGroup else { return }
        if joinGroup.createdUserId != AuthManager.shared.currentUser {
            self.viewModel.joinGroup(uuid: joinGroup.uuid) {
                self.dismiss(animated: true)
            } failure: { error in
                print(error)
            }
        } else {
            var joinUsersId = [AuthManager.shared.currentUser]
            self.joinUsers?.forEach({joinUsersId.append($0.userId)})
            self.viewModel.setGroupPlan(name: joinGroup.planName,
                                         times: joinGroup.planTimes,
                                         days: joinGroup.planDays,
                                         uuid: joinGroup.uuid)
            self.viewModel.createGroupPlan(uuid: joinGroup.uuid, joinUsers: joinUsersId, completion: { result in
                switch result {
                case .success(let string):
                    print(string)
                case .failure(let error):
                    print(error)
                }
            })
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            if let tabBarController = self.presentingViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
            }
        }
    }
    @IBAction func leaveButtonTap(_ sender: UIButton) {
        guard let joinGroup = joinGroup else { return }
        if joinGroup.createdUserId == AuthManager.shared.currentUser {
            self.viewModel.deleteJoinGroup(uuid: joinGroup.uuid) { result in
                switch result {
                case .success(let string):
                    print(string)
                    self.dismiss(animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            self.viewModel.leaveJoinGroup(uuid: joinGroup.uuid,
                                           userId: AuthManager.shared.currentUser,
                                           completion: { result in
                switch result {
                case .success(let string):
                    print(string)
                    self.dismiss(animated: true)
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(UINib(nibName: "\(GroupPlanViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(GroupPlanViewCell.self)")
        
        collectionView.register(UINib(nibName: "\(GroupPlanHeaderView.self)", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(GroupPlanHeaderView.self)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
//                                                       subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
        
        item.contentInsets =  NSDirectionalEdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        
        let innergroup =
        NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.22),
                                                     heightDimension: .fractionalHeight(0.09))
        let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innergroup])
        let section = NSCollectionLayoutSection(group: nestedGroup)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind:
                                                                    UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func setupLayout() {
        collectionView.layer.cornerRadius = 25
        planJoinButton.layer.cornerRadius = 15
        planLeaveButton.layer.cornerRadius = 15
        guard let joinGroup = joinGroup else { return }
        switch joinGroup.planName {
        case PlanExercise.squat.rawValue:
            groupPlanImageView.image = UIImage.groupSquat
        case PlanExercise.plank.rawValue:
            groupPlanImageView.image = UIImage.groupPlank
        case PlanExercise.pushup.rawValue:
            groupPlanImageView.image = UIImage.groupPushup
        default:
            groupPlanImageView.image = UIImage.placeHolder
        }
    }
}

extension GroupPlanViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.joinUsersViewModel.value.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(GroupPlanViewCell.self)",
            for: indexPath) as? GroupPlanViewCell else {
            return UICollectionViewCell()
        }
        let cellViewModel = self.viewModel.joinUsersViewModel.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(GroupPlanHeaderView.self)",
            for: indexPath) as? GroupPlanHeaderView else {
            return UICollectionReusableView()
        }
        if joinGroup?.createdUser?.picture == "" {
            headerView.planCreatedUserIamgeView.image = UIImage.placeHolder
        } else {
            headerView.planCreatedUserIamgeView.loadImage(joinGroup?.createdUser?.picture)
        }
        headerView.planCreatedNameLabel.text = joinGroup?.createdUser?.name
        headerView.planTimesLabel.text = "\(joinGroup?.planTimes ?? "")次/秒，持續\(joinGroup?.planDays ?? "")天"
        headerView.planTitleLabel.text = joinGroup?.planName

        return headerView
    }
}
