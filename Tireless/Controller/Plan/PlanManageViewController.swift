//
//  PersonalPlanViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import UIKit

class PlanManageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = PlanManageViewModel()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, SectionItem>
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SectionItem>
    
    private var dataSource: DataSource?
    
    private var planEmptyView = UIImageView()
    
    enum SectionItem: Hashable {
        case plan(Plan)
        case groupPlan(GroupPlan)
    }
    
    var plan: [Plan]? {
        didSet {
            dataSource?.apply(snapshot(), animatingDifferences: false)
            if plan == [], groupPlans == [] {
                planEmptyView.isHidden = false
                collectionView.isHidden = true
            } else {
                planEmptyView.isHidden = true
                collectionView.isHidden = false
            }
        }
    }
    
    private var groupPlans: [GroupPlan]? {
        didSet {
            dataSource?.apply(snapshot(), animatingDifferences: false)
            if plan == [], groupPlans == [] {
                planEmptyView.isHidden = false
                collectionView.isHidden = true
            } else {
                planEmptyView.isHidden = true
                collectionView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlanEmptyView()
        self.view.backgroundColor = .themeBG
        
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = .themeBG
        
        configureCollectionView()
        configureDataSource()
        configureDataSourceProvider()
        configureDataSourceSnapshot()
        
        viewModel.plan.bind { [weak self] plan in
            self?.plan = plan
        }
        
        viewModel.groupPlan.bind { [weak self] groupPlans in
            self?.groupPlans = groupPlans
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if AuthManager.shared.currentUser != "" {
            self.viewModel.fetchPlan()
        }
    }
    
    private func setPlanEmptyView() {
        planEmptyView.image = UIImage(named: "TirelessLogo")
        planEmptyView.contentMode = .scaleAspectFill
        self.view.addSubview(planEmptyView)
        planEmptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            planEmptyView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            planEmptyView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            planEmptyView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            planEmptyView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2)
        ])
        
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
            case .plan(let plan):
                cell.planDeleteButton.isHidden = false
                cell.planSettingButton.isHidden = false
                cell.isStartButtonTap = { [weak self] in
                    self?.present(target: plan.planTimes, plan: plan)
                }
                
                cell.isDeleteButtonTap = { [weak self] in
                    self?.showDeleteAlert(plan: plan)
                }
                cell.isSettingButtonTap = { [weak self] in
                    self?.showSettingAlert(plan: plan)
                }
                switch plan.planName {
                case "深蹲":
                    cell.planImageView.image = UIImage(named: "pexels_squat")
                    cell.planTimesLabel.text = "\(plan.planTimes)次/\(plan.planDays)天"
                case "棒式":
                    cell.planImageView.image = UIImage(named: "pexels_plank")
                    cell.planTimesLabel.text = "\(plan.planTimes)秒/\(plan.planDays)天"
                case "伏地挺身":
                    cell.planImageView.image = UIImage(named: "pexels_pushup")
                    cell.planTimesLabel.text = "\(plan.planTimes)次/\(plan.planDays)天"
                default:
                    cell.planImageView.image = UIImage(named: "Cover")
                }
                
                cell.planTitleLabel.text = "\(plan.planName)"
                cell.planProgressView.alpha = 1
                cell.planProgressView.progress = Float(plan.progress)
                
                return cell
            case .groupPlan(let groupPlan):
                cell.planSettingButton.isHidden = true
                if groupPlan.createdUserId == AuthManager.shared.currentUser {
                    cell.planDeleteButton.isHidden = false
                } else {
                    cell.planDeleteButton.isHidden = true
                }
                cell.isStartButtonTap = { [weak self] in
                    self?.present(target: groupPlan.planTimes, groupPlan: groupPlan)
                }
                
                cell.planTitleLabel.text = groupPlan.planName
                switch groupPlan.planName {
                case "深蹲":
                    cell.planImageView.image = UIImage(named: "pexels_squat")
                    cell.planTimesLabel.text = "\(groupPlan.planTimes)次/\(groupPlan.planDays)天"
                case "棒式":
                    cell.planImageView.image = UIImage(named: "pexels_plank")
                    cell.planTimesLabel.text = "\(groupPlan.planTimes)秒/\(groupPlan.planDays)天"
                case "伏地挺身":
                    cell.planImageView.image = UIImage(named: "pexels_pushup")
                    cell.planTimesLabel.text = "\(groupPlan.planTimes)次/\(groupPlan.planDays)天"
                default:
                    cell.planImageView.image = UIImage(named: "Cover")
                }
                cell.planProgressView.alpha = 0
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
        if let plan = plan {
            snapshot.appendItems(plan.map({SectionItem.plan($0)}), toSection: 0)
            snapshot.reloadItems(plan.map({SectionItem.plan($0)}))
        }
        if let groupPlans = groupPlans {
            snapshot.appendItems(groupPlans.map({SectionItem.groupPlan($0)}), toSection: 1)
            snapshot.reloadItems(groupPlans.map({SectionItem.groupPlan($0)}))
        }
        return snapshot
    }
    
    private func present(target: String, plan: Plan? = nil, groupPlan: GroupPlan? = nil) {
        guard let poseVC = UIStoryboard.home.instantiateViewController(
            withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
        poseVC.planTarget = Int(target) ?? 0
        poseVC.plan = plan
        poseVC.groupPlan = groupPlan
        poseVC.modalPresentationStyle = .fullScreen
        self.present(poseVC, animated: true)
    }
    
    private func showDeleteAlert(plan: Plan) {
        let alertController = UIAlertController(title: "確認刪除!",
                                                message: "刪除的計畫無法再度復原!",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { [weak self] _ in
            self?.viewModel.deletePlan(uuid: plan.uuid)
            var snapshot = self?.dataSource?.snapshot()
            snapshot?.deleteItems([SectionItem.plan(plan)])
            self?.dataSource?.apply(snapshot!, animatingDifferences: false)
            alertController.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    private func showSettingAlert(plan: Plan) {
        let alertController = UIAlertController(title: "計畫修改",
                                                message: "可以調整計畫的次數",
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "次數"
            textField.keyboardType = .phonePad
        }
        let okAction = UIAlertAction(title: "修改", style: .destructive) { _ in
            let times = alertController.textFields?[0].text
            guard let times = times else {
                return
            }
            PlanManager.shared.modifyPlan(planUid: plan.uuid,
                                          times: times) { result in
                switch result {
                case .success(let text):
                    print(text)
                case .failure(let error):
                    print(error)
                }
            }
            alertController.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
