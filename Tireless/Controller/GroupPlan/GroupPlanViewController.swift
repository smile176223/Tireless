//
//  GroupPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/25.
//

import UIKit

class GroupPlanViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet private weak var groupPlanImageView: UIImageView!
    
    @IBOutlet private weak var planLeaveButton: UIButton!
    
    @IBOutlet private weak var planJoinButton: UIButton!
    
    var joinGroup: JoinGroup?

    var viewModel: JoinGroupViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureCollectionView()
        
        viewModel?.joinUsersViewModel.bind { [weak self] users in
            if users.contains(where: { $0.user.userId == AuthManager.shared.currentUser }) {
                DispatchQueue.main.async {
                    self?.planJoinButton.isEnabled = false
                    self?.planJoinButton.setTitle("已加入", for: .normal)
                    self?.planLeaveButton.isHidden = false
                }
            }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.fetchJoinUsers()
        
        if viewModel.checkGroupOwner() {
            planJoinButton.setTitle("開始計畫", for: .normal)
            planLeaveButton.isHidden = false
            planLeaveButton.setTitle("放棄計畫", for: .normal)
        }
    }
    
    @IBAction func backButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBAction func joinButtonTap(_ sender: UIButton) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.startGroup {
            self.dismiss(animated: true)
        } createDone: {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            if let tabBarController = self.presentingViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
            }
        }
    }
    @IBAction func leaveButtonTap(_ sender: UIButton) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.stopGroup {
            self.dismiss(animated: true)
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
        
        item.contentInsets =  NSDirectionalEdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        
        let innergroup =
        NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                     heightDimension: .absolute(50))
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
        viewModel?.joinUsersViewModel.value.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(GroupPlanViewCell.self)",
            for: indexPath) as? GroupPlanViewCell else {
            return UICollectionViewCell()
        }
        guard let cellViewModel = self.viewModel?.joinUsersViewModel.value[indexPath.row] else {
            return UICollectionViewCell()
        }
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
        guard let headerViewModel = self.viewModel?.joinGroup else {
            return UICollectionReusableView()
        }
        headerView.setup(viewModel: headerViewModel)

        return headerView
    }
}
