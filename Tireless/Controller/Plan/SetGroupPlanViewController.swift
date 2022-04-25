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
        }
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, SectionItem>
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SectionItem>
    
    private var dataSource: DataSource?
    
    var plans: [Plans]?
    
    var selectPlan: Plans? {
        didSet {
            dataSource?.apply(snapshot(), animatingDifferences: false)
        }
    }
    
    let viewModel = SetGroupPlanViewModel()
    
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
    
    enum SectionItem: Hashable {
        case plan(Plans)
        case detail(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureDataSource()
        configureDataSourceProvider()
        configureDataSourceSnapshot()
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
            NSCollectionLayoutDimension.fractionalHeight(0.6) : NSCollectionLayoutDimension.absolute(100)
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
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "\(HomeViewCell.self)",
                for: indexPath) as? HomeViewCell else { return UICollectionViewCell() }

            guard let detailCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "\(SetGroupPlanDetailViewCell.self)",
                for: indexPath) as? SetGroupPlanDetailViewCell else { return UICollectionViewCell() }
            
            switch item {
            case .plan(let plans):
                cell.textLabel.text = plans.planName
                cell.textLabel.font = .bold(size: 20)
                cell.imageView.image = UIImage(named: plans.planImage)
                return cell
            case .detail(let text):
                detailCell.groupPlanDetailLabel.text = text
                detailCell.groupCreatedUserLabel.text = "發起人：\(DemoUser.demoName)"
                detailCell.isCreateButtonTap = { days, times in
                    if let selectPlan = self.selectPlan {
                        self.viewModel.getPlanData(name: selectPlan.planName,
                                              times: times,
                                              days: days,
                                              createdName: DemoUser.demoName,
                                              createdUserId: DemoUser.demoUser)
                        self.viewModel.createPlan(
                            success: {
                                self.dismiss(animated: true)
                            }, failure: { error in
                                print(error)
                            })
                    }
                }
                return detailCell
            }
        })
    }
    
    private func configureDataSourceProvider() {
        dataSource?.supplementaryViewProvider = { (collectionView, _, indexPath) in
            guard let headerView = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "\(HomeHeaderView.self)",
                for: indexPath) as? HomeHeaderView else { return UICollectionReusableView()}
        
            if indexPath.section == 0 {
                headerView.textLabel.text = "發起揪團"
                headerView.textLabel.textAlignment = .center
            }

            return headerView
        }
    }
    
    private func configureDataSourceSnapshot() {
        dataSource?.apply(snapshot(), animatingDifferences: false)
    }
    
    private func snapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([0, 1])
        snapshot.appendItems([SectionItem.detail(selectPlan?.planDetail ?? "")], toSection: 1)
        if let plans = plans {
            snapshot.appendItems(plans.map({SectionItem.plan($0)}), toSection: 0)
        }
        return snapshot
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
                self.selectPlan = self.plans?[indexPath.row]
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            cell?.layer.borderWidth = 0
        }
    }
}
