//
//  PersonalPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import UIKit

class PlanManageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let personal = [Plan(planName: "深蹲：每天10次/10天", planDetail: "", planImage: "pexels_squat")]
    let group = [Plan]()
    
    enum Section: Int, CaseIterable {
        case personalPlan
        case groupPlan
        
        var columnCount: Int {
            switch self {
            case .personalPlan:
                return 1
            case .groupPlan:
                return 0
            }
        }
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Plan>
    
    private var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .themeBG
        
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = .themeBG
        
        configureCollectionView()
        configureDataSource()
        configureDataSourceProvider()
        configureDataSourceSnapshot()
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(UINib(nibName: "\(PlanManageViewCell.self)", bundle: nil),
                                forCellWithReuseIdentifier: "\(PlanManageViewCell.self)")
        
        collectionView.register(HomeHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(HomeHeaderView.self)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .absolute(130))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 5, leading: 15, bottom: 5, trailing: 15)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PlanManageViewCell.self)",
                                                                for: indexPath) as? PlanManageViewCell else {
                return UICollectionViewCell()
            }
            
            cell.isStartButtonTap = {
                self.present()
            }
            
            cell.planImageView.layer.cornerRadius = cell.planImageView.frame.height / 2
            cell.planImageView.image = UIImage(named: "pexels_squat")
            
            cell.planProgressView.progress = 0.5
            
            cell.layer.cornerRadius = 20
   
            cell.planTitleLabel.text = "\(item.planName)"
            
            return cell
        })
    }
    private func configureDataSourceProvider() {
        dataSource?.supplementaryViewProvider = { (collectionView, _, indexPath) in
            guard let headerView = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "\(HomeHeaderView.self)",
                for: indexPath) as? HomeHeaderView else { return UICollectionReusableView()}
        
            if indexPath.section == 0 {
                headerView.textLabel.text = "個人計畫"
            } else if indexPath.section == 1 {
                headerView.textLabel.text = "團體計劃"
            }
            return headerView
        }
    }
    
    private func configureDataSourceSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Plan>()
        snapshot.appendSections([.personalPlan, .groupPlan])
        snapshot.appendItems(personal, toSection: .personalPlan)
        snapshot.appendItems(group, toSection: .groupPlan)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func present() {
        guard let poseVC = UIStoryboard.home.instantiateViewController(
            withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
        poseVC.modalPresentationStyle = .fullScreen
        self.present(poseVC, animated: true)
    }
        
}
