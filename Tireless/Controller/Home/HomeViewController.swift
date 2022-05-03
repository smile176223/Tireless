//
//  HomeViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    let viewModel = HomeViewModel()
    
    enum Section: Int, CaseIterable {
        case daily
        case personalPlan
        case joinGroup

        var columnCount: Int {
            switch self {
            case .daily:
                return 5
            case .personalPlan:
                return 3
            case .joinGroup:
                return 3
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themeBG

        navigationController?.navigationBar.isHidden = true
        
        configureCollectionView()

        viewModel.setDefault()
        
        viewModel.joinGroupsViewModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.collectionView.reloadData()
            }
        }
        AuthManager.shared.getCurrentUser { result in
            switch result {
            case .success(let bool):
                if bool == true {
                    self.viewModel.fetchJoinGroup(userId: AuthManager.shared.currentUser)
                }
            case .failure(let error):
                print(error)
            }
        }
        
        if AuthManager.shared.currentUser != "" {
            viewModel.fetchJoinGroup(userId: AuthManager.shared.currentUser)
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if AuthManager.shared.currentUser != "" {
//            viewModel.fetchJoinGroup(userId: AuthManager.shared.currentUser)
//        }
//    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(HomeDailyHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(HomeDailyHeaderView.self)")
        
        collectionView.register(HomeHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(HomeHeaderView.self)")
        
        collectionView.register(UINib(nibName: "\(HomeDailyViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(HomeDailyViewCell.self)")
        
        collectionView.register(UINib(nibName: "\(HomeGroupPlanViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(HomeGroupPlanViewCell.self)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {(sectionIndex, _) -> NSCollectionLayoutSection? in
            guard let sectionType = Section(rawValue: sectionIndex) else {
                return nil
            }
            var columns = sectionType.columnCount
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            var groupHeight = NSCollectionLayoutDimension.absolute(1)
            if sectionIndex == 0 {
                groupHeight = NSCollectionLayoutDimension.absolute(90)
            } else if sectionIndex == 1 {
                groupHeight = NSCollectionLayoutDimension.absolute(400)
            } else {
                groupHeight = NSCollectionLayoutDimension.absolute(150)
            }
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            if sectionIndex == 2 {
                if self.viewModel.joinGroupsViewModel.value.count != 0 {
                    columns = 3
                } else {
                    columns = 1
                }
            }
            let innergroup = sectionIndex == 1 ?
            NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: columns) :
            NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                         heightDimension: groupHeight)
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innergroup])
            let section = NSCollectionLayoutSection(group: nestedGroup)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            let headerSize = sectionIndex == 0 ?
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)) :
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind:
                                                                        UICollectionView.elementKindSectionHeader,
                                                                     alignment: .top)
            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 15, trailing: 15)
            return section
        }
        return layout
    }
    
}
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return Section.daily.columnCount
        } else if section == 1 {
            return Section.personalPlan.columnCount
        } else {
            if viewModel.joinGroupsViewModel.value.count == 0 {
                return 1
            } else {
                return viewModel.joinGroupsViewModel.value.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(HomeViewCell.self)",
            for: indexPath) as? HomeViewCell else {
            return UICollectionViewCell()
        }
        guard let dailyCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(HomeDailyViewCell.self)",
            for: indexPath) as? HomeDailyViewCell else {
            return UICollectionViewCell()
        }
        guard let groupCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(HomeGroupPlanViewCell.self)",
            for: indexPath) as? HomeGroupPlanViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.section == 0 {
            if indexPath.section == 0, indexPath.row == 2 {
                dailyCell.contentView.backgroundColor = .themeYellow
            } else {
                dailyCell.contentView.backgroundColor = .white
            }
            dailyCell.dailyWeekDayLabel.text = viewModel.weeklyDay[indexPath.row].weekDays
            dailyCell.dailyDayLabel.text = viewModel.weeklyDay[indexPath.row].days
            return dailyCell
        } else if indexPath.section == 1 {
            let cellViewModel = self.viewModel.defaultPlansViewModel.value[indexPath.row]
            cell.setup(viewModel: cellViewModel)
            return cell
        } else {
            if viewModel.joinGroupsViewModel.value.count != 0 {
                let cellViewModel = self.viewModel.joinGroupsViewModel.value[indexPath.row]
                groupCell.setup(viewModel: cellViewModel)
                groupCell.groupUserImageView.isHidden = false
                groupCell.groupUserNameLabel.isHidden = false
                groupCell.groupTitleLabel.isHidden = false
                groupCell.isUserInteractionEnabled = true
            } else {
                groupCell.groupImageView.image = UIImage(named: "tireless_nogroup")
                groupCell.groupImageView.alpha = 1
                groupCell.groupUserImageView.isHidden = true
                groupCell.groupUserNameLabel.isHidden = true
                groupCell.groupTitleLabel.isHidden = true
                groupCell.isUserInteractionEnabled = false
            }
            
            return groupCell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = self.collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(HomeHeaderView.self)",
            for: indexPath) as? HomeHeaderView else { return UICollectionReusableView() }
        guard let headerDailyView = self.collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(HomeDailyHeaderView.self)",
            for: indexPath) as? HomeDailyHeaderView else { return UICollectionReusableView() }

        headerView.isCreateButtonTap = { [weak self] in
            guard let setGroupPlanVC = UIStoryboard.groupPlan.instantiateViewController(
                withIdentifier: "\(SetGroupPlanViewController.self)")
                    as? SetGroupPlanViewController
            else {
                return
            }
            setGroupPlanVC.plans = self?.viewModel.plans
            self?.present(setGroupPlanVC, animated: true)
        }

        if indexPath.section == 0 {
            return headerDailyView
        } else if indexPath.section == 1 {
            headerView.textLabel.text = "建立個人計畫"
            headerView.createGroupButton.isHidden = true
            return headerView
        } else if indexPath.section == 2 {
            headerView.textLabel.text = "揪團計畫"
            headerView.createGroupButton.isHidden = false
            return headerView
        }
        return UICollectionReusableView()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            guard let detailVC = UIStoryboard.home.instantiateViewController(
                withIdentifier: "\(PlanDetailViewController.self)")
                    as? PlanDetailViewController
            else {
                return
            }
            detailVC.plan = viewModel.defaultPlansViewModel.value[indexPath.row].defaultPlans
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)
        } else if indexPath.section == 2 {
            guard let groupVC = UIStoryboard.groupPlan.instantiateViewController(
                withIdentifier: "\(GroupPlanViewController.self)")
                    as? GroupPlanViewController
            else {
                return
            }
            groupVC.joinGroup = viewModel.joinGroupsViewModel.value[indexPath.row].joinGroup
            groupVC.modalPresentationStyle = .fullScreen
            self.present(groupVC, animated: true)
        }
    }
}
