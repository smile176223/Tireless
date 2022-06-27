//
//  GroupPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class SetGroupPlanViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    var viewModel: SetGroupPlanViewModel?
    
    let homeViewModel = HomeViewModel()
    
    enum Section: Int, CaseIterable {
        case plan
        case detail
        
        var columnCount: Int {
            switch self {
            case .plan:
                return 3
            case .detail:
                return 1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        
        homeViewModel.defaultPlansViewModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel?.selectPlan.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeViewModel.setDefault()
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(UINib(nibName: "\(SetGroupPlanDetailViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(SetGroupPlanDetailViewCell.self)")
        
        collectionView.register(HomeHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(HomeHeaderView.self)")
        
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
            NSCollectionLayoutDimension.fractionalHeight(0.6) : NSCollectionLayoutDimension.fractionalHeight(0.2)
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

            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 15)

            return section
        }

        return layout
   
    }
    
    func authPresent() {
        if let authVC = UIStoryboard.auth.instantiateInitialViewController() {
            present(authVC, animated: true, completion: nil)
        }
    }
}

extension SetGroupPlanViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return homeViewModel.defaultPlansViewModel.value.count
        } else {
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(HomeViewCell.self)",
            for: indexPath) as? HomeViewCell else {
            return UICollectionViewCell()
        }

        guard let detailCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(SetGroupPlanDetailViewCell.self)",
            for: indexPath) as? SetGroupPlanDetailViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.section == 0 {
            let cellViewModel = homeViewModel.defaultPlansViewModel.value[indexPath.row]
            cell.setupGroup(viewModel: cellViewModel)
            cell.textLabel.font = .bold(size: 20)
            return cell
        } else {
            if let selectPlan = viewModel?.selectPlan.value {
                detailCell.groupPlanDetailLabel.text = selectPlan.planDetail
            } else {
                detailCell.groupPlanDetailLabel.text = ""
            }
            detailCell.groupCreatedUserLabel.text = "發起人：\(viewModel?.getCurrentUserName() ?? "")"
            detailCell.createButtonTapped = { [weak self] days, times in
                self?.viewModel?.createPlan(times: times,
                                            days: days,
                                            success: {
                    self?.dismiss(animated: true)
                }, needLogin: {
                    self?.authPresent()
                })
            }
            
            return detailCell
            
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = self.collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(HomeHeaderView.self)",
            for: indexPath) as? HomeHeaderView else { return UICollectionReusableView()}
        if indexPath.section == 0 {
            headerView.textLabel.isHidden = false
            headerView.textLabel.text = "發起揪團"
            headerView.textLabel.textAlignment = .center
        } else {
            headerView.textLabel.isHidden = true
        }
        return headerView
    }
}

extension SetGroupPlanViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if indexPath.section == 0 {
            UIView.animate(withDuration: 0.3) {
                cell?.layer.borderWidth = 5.0
                let color = UIColor.themeYellow
                cell?.layer.borderColor = color?.cgColor
                self.viewModel?.userSelectPlan(index: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if indexPath.section == 0 {
            UIView.animate(withDuration: 0.3) {
                cell?.layer.borderWidth = 0
            }
        }
    }
}
