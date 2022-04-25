//
//  PersonalPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import UIKit
import MapKit

class PlanManageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = FetchPlanViewModel()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, SectionItem>
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SectionItem>
    
    private var dataSource: DataSource?
    
    enum SectionItem: Hashable {
        case personalPlan(PersonalPlan)
        case groupPlan(GroupPlan)
    }
    
    private var personalPlans: [PersonalPlan]? {
        didSet {
            dataSource?.apply(snapshot(), animatingDifferences: false)
        }
    }
    
    private var groupPlans: [GroupPlan]? {
        didSet {
            dataSource?.apply(snapshot(), animatingDifferences: false)
        }
    }
    
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
        
        viewModel.personalPlan.bind { personalPlans in
            self.personalPlans = personalPlans
        }
        
        viewModel.groupPlan.bind { groupPlans in
            self.groupPlans = groupPlans
        }
        
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
            switch item {
            case .personalPlan(let personalPlan):
                cell.isStartButtonTap = {
                    self.present(target: personalPlan.planTimes, personalPlan: personalPlan)
                }
                
                cell.isDeleteButtonTap = {
                    let alertController = UIAlertController(title: "確認刪除!", message: "刪除的計畫無法再度復原!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "確定", style: .destructive) { _ in
                        self.viewModel.deletePlan(uuid: personalPlan.uuid)
                        var snapshot = self.dataSource?.snapshot()
                        snapshot?.deleteItems([SectionItem.personalPlan(personalPlan)])
                        self.dataSource?.apply(snapshot!, animatingDifferences: true)
                        alertController.dismiss(animated: true)
                    }
                    let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in
                        alertController.dismiss(animated: true)
                    }
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true)
                }
                switch personalPlan.planName {
                case "深蹲":
                    cell.planImageView.image = UIImage(named: "pexels_squat")
                    cell.planTimesLabel.text = "\(personalPlan.planTimes)次/\(personalPlan.planDays)天"
                case "棒式":
                    cell.planImageView.image = UIImage(named: "pexels_plank")
                    cell.planTimesLabel.text = "\(personalPlan.planTimes)秒/\(personalPlan.planDays)天"
                case "伏地挺身":
                    cell.planImageView.image = UIImage(named: "pexels_pushup")
                    cell.planTimesLabel.text = "\(personalPlan.planTimes)次/\(personalPlan.planDays)天"
                    
                default:
                    cell.planImageView.image = UIImage(named: "Cover")
                }
                
                cell.planTitleLabel.text = "\(personalPlan.planName)"
                cell.planProgressView.progress = Float(personalPlan.progress)
                
                return cell
            case .groupPlan(let groupPlan):
                cell.planTitleLabel.text = groupPlan.planName
            }
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
        dataSource?.apply(snapshot(), animatingDifferences: false)
    }
    
    private func snapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([0, 1])
        if let personalPlans = personalPlans {
            snapshot.appendItems(personalPlans.map({SectionItem.personalPlan($0)}), toSection: 0)
            snapshot.reloadItems(personalPlans.map({SectionItem.personalPlan($0)}))
        }
        if let groupPlans = groupPlans {
            snapshot.appendItems(groupPlans.map({SectionItem.groupPlan($0)}), toSection: 1)
            snapshot.reloadItems(groupPlans.map({SectionItem.groupPlan($0)}))
        }
        return snapshot
    }
    
    private func present(target: String, personalPlan: PersonalPlan) {
        guard let poseVC = UIStoryboard.home.instantiateViewController(
            withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
        poseVC.planTarget = Int(target) ?? 0
        poseVC.personalPlan = personalPlan
        poseVC.modalPresentationStyle = .fullScreen
        self.present(poseVC, animated: true)
    }
}
