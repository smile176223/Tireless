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
    
    var plans: [DefaultPlans]?
    
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
 
    private var joinGroup: [JoinGroup]? {
        didSet {
//            dataSource?.apply(snapshot(), animatingDifferences: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themeBG

        navigationController?.navigationBar.isHidden = true
        
        configureCollectionView()

        viewModel.setDefault()
        
        viewModel.joinGroup.bind { [weak self] joinGroup in
            self?.joinGroup = joinGroup
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if AuthManager.shared.currentUser != "" {
            viewModel.fetchJoinGroup(userId: AuthManager.shared.currentUser)
        }
    }
    
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
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {(sectionIndex, _) -> NSCollectionLayoutSection? in
            guard let sectionType = Section(rawValue: sectionIndex) else {
                return nil
            }

            let columns = sectionType.columnCount

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let groupHeight = sectionIndex == 1 ?
            NSCollectionLayoutDimension.absolute(400) : NSCollectionLayoutDimension.absolute(90)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            let innergroup = sectionIndex == 1 ?
            NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item,
                                               count: columns) :
            NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item,
                                               count: columns)

            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                         heightDimension: groupHeight)
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innergroup])

            let section = NSCollectionLayoutSection(group: nestedGroup)
            section.orthogonalScrollingBehavior = .groupPagingCentered

            let headerSize = sectionIndex == 0 ?
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)) :
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
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
            return 0
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
        if indexPath.section == 0 {
            if indexPath.section == 0, indexPath.row == 2 {
                dailyCell.contentView.backgroundColor = .themeYellow
            }
            dailyCell.dailyWeekDayLabel.text = viewModel.weeklyDay[indexPath.row].weekDays
            dailyCell.dailyDayLabel.text = viewModel.weeklyDay[indexPath.row].days
            return dailyCell
        } else if indexPath.section == 1 {
            let cellViewModel = self.viewModel.defaultPlanss.value[indexPath.row]
            cell.setup(viewModel: cellViewModel)
            return cell
        } else {
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = self.collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(HomeHeaderView.self)",
            for: indexPath) as? HomeHeaderView else { return UICollectionReusableView()}
        guard let headerDailyView = self.collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(HomeDailyHeaderView.self)",
            for: indexPath) as? HomeDailyHeaderView else { return UICollectionReusableView()}

        headerView.isCreateButtonTap = { [weak self] in
            guard let setGroupPlanVC = UIStoryboard.groupPlan.instantiateViewController(
                withIdentifier: "\(SetGroupPlanViewController.self)")
                    as? SetGroupPlanViewController
            else {
                return
            }
            setGroupPlanVC.plans = self?.plans
            self?.present(setGroupPlanVC, animated: true)
        }

        if indexPath.section == 0 {
            return headerDailyView
        } else if indexPath.section == 1 {
            headerView.textLabel.text = "個人計畫"
            headerView.createGroupButton.isHidden = true
        } else if indexPath.section == 2 {
            headerView.textLabel.text = "團體計劃"
            headerView.createGroupButton.isHidden = false
        }
        return headerView
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
            detailVC.plan = viewModel.defaultPlanss.value[indexPath.row].defaultPlans
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)
        } else if indexPath.section == 2 {
            guard let groupVC = UIStoryboard.groupPlan.instantiateViewController(
                withIdentifier: "\(GroupPlanViewController.self)")
                    as? GroupPlanViewController
            else {
                return
            }
            groupVC.joinGroup = self.joinGroup?[indexPath.row]
            guard let plans = plans else { return }
            switch joinGroup?[indexPath.row].planName {
            case "深蹲":
                groupVC.plan = plans[0]
            case "棒式":
                groupVC.plan = plans[1]
            case "伏地挺身":
                groupVC.plan = plans[2]
            case .none:
                print("none")
            case .some(let string):
                print(string)
            }
            groupVC.modalPresentationStyle = .fullScreen
            self.present(groupVC, animated: true)
        }
    }
}
