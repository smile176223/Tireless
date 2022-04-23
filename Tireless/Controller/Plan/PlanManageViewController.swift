//
//  PersonalPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import UIKit

class PlanManageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = FetchPlanViewModel()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, PlanManage>
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, PlanManage>
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fatchPlan()
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
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60)) 
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind:
                                                                    UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)

        section.boundarySupplementaryItems = [header]
        
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
            
            cell.isDeleteButtonTap = {
                self.viewModel.deletePlan(uuid: item.uuid)
                var snapshot = self.dataSource?.snapshot()
                snapshot?.deleteItems([item])
//                self.dataSource?.apply(snapshot!, animatingDifferences: true)
                self.dataSource?.apply(snapshot!, animatingDifferences: true)
            }
            switch item.planName {
            case "深蹲":
                cell.planImageView.image = UIImage(named: "pexels_squat")
                cell.planTimesLabel.text = "\(item.planTimes)次/\(item.planDays)天"
            case "棒式":
                cell.planImageView.image = UIImage(named: "pexels_plank")
                cell.planTimesLabel.text = "\(item.planTimes)秒/\(item.planDays)天"
            case "伏地挺身":
                cell.planImageView.image = UIImage(named: "pexels_pushup")
                cell.planTimesLabel.text = "\(item.planTimes)次/\(item.planDays)天"
                
            default:
                cell.planImageView.image = UIImage(named: "Cover")
            }
   
            cell.planTitleLabel.text = "\(item.planName)"
            cell.planProgressView.progress = Float(item.progress)
            
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
        var snapshot = Snapshot()
        snapshot.appendSections([0, 1])
        
        viewModel.planManage.bind { plan in
            snapshot.appendItems(plan, toSection: 0)
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
        
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
