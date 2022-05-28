//
//  PlanManageViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import UIKit

class PlanManageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    let viewModel = PlanManageViewModel()
    
    private var planEmptyView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlanEmptyView()
        self.view.backgroundColor = .themeBG
        
        planEmptyView.isHidden = true
        
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = .themeBG
        
        configureCollectionView()
        
        viewModel.planViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.groupPlanViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if AuthManager.shared.currentUser != "" {
            self.viewModel.fetchPlan()
        } else {
            self.viewModel.logoutReset()
        }
    }
    
    private func setPlanEmptyView() {
        planEmptyView.image = UIImage(named: "tireless_noplan")
        planEmptyView.contentMode = .scaleAspectFit
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
    
    private func present(target: String, plan: Plan) {
        guard let poseVC = UIStoryboard.poseDetect.instantiateViewController(
            withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
        poseVC.viewModel = PoseDetectViewModel(plan: plan)
        poseVC.modalPresentationStyle = .fullScreen
        self.present(poseVC, animated: true)
    }
    
    private func groupPlanPresent(plan: Plan) {
        guard let groupVC = storyboard?.instantiateViewController(
            withIdentifier: "\(GroupPlanStatusViewController.self)")
                as? GroupPlanStatusViewController
        else {
            return
        }
//        groupVC.plan = plan
        groupVC.viewModel = GroupPlanStatusViewModel(plan: plan)
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    private func planReviewPresent(plan: Plan) {
        guard let reviewVC = storyboard?.instantiateViewController(
            withIdentifier: "\(PlanReviewViewController.self)")
                as? PlanReviewViewController
        else {
            return
        }
        reviewVC.viewModel = PlanReviewViewModel(plan: plan)
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    private func planModifyPresent(plan: Plan) {
        guard let modifyVC = UIStoryboard.plan.instantiateViewController(
            withIdentifier: "\(PlanModifyViewController.self)")
                as? PlanModifyViewController
        else {
            return
        }
        modifyVC.viewModel = PlanModifyViewModel(plan: plan)
        modifyVC.modalPresentationStyle = .overCurrentContext
        modifyVC.modalTransitionStyle = .crossDissolve
        present(modifyVC, animated: true)
    }
}

extension PlanManageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (viewModel.planViewModels.value.count + viewModel.groupPlanViewModels.value.count) == 0 {
            collectionView.isHidden = true
            planEmptyView.isHidden = false
        } else {
            collectionView.isHidden = false
            planEmptyView.isHidden = true
        }
        if section == 0 {
            return viewModel.planViewModels.value.count
        } else {
            return viewModel.groupPlanViewModels.value.count
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(PlanManageViewCell.self)", for: indexPath) as? PlanManageViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.section == 0 {
            let cellViewModel = self.viewModel.planViewModels.value[indexPath.row]
            cell.setup(viewModel: cellViewModel)
            cell.isDeleteButtonTap = {
                self.setUserAlert(plan: cellViewModel.plan)
            }
            cell.isStartButtonTap = {
                self.present(target: cellViewModel.plan.planTimes, plan: cellViewModel.plan)
            }
        } else {
            let cellViewModel = self.viewModel.groupPlanViewModels.value[indexPath.row]
            cell.setup(viewModel: cellViewModel)
            cell.isStartButtonTap = {
                self.present(target: cellViewModel.plan.planTimes, plan: cellViewModel.plan)
            }
            cell.isDeleteButtonTap = {
                self.setUserAlert(plan: cellViewModel.plan)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(HomeHeaderView.self)",
            for: indexPath) as? HomeHeaderView else {
            return UICollectionReusableView()
        }
        if indexPath.section == 0 {
            headerView.textLabel.text = "個人計畫"
        } else {
            headerView.textLabel.text = "團體計畫"
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cellViewModel = self.viewModel.planViewModels.value[indexPath.row]
            planReviewPresent(plan: cellViewModel.plan)
        } else {
            let cellViewModel = self.viewModel.groupPlanViewModels.value[indexPath.row]
            groupPlanPresent(plan: cellViewModel.plan)
        }
    }
}

extension PlanManageViewController {
    private func showDeleteAlert(plan: Plan) {
        let alertController = UIAlertController(title: "確認刪除!",
                                                message: "刪除的計畫無法再度復原!",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            PlanManager.shared.deletePlan(userId: AuthManager.shared.currentUser, plan: plan) { result in
                switch result {
                case .success(let text):
                    ProgressHUD.showSuccess(text: "刪除計畫成功")
                    print(text)
                case .failure(let error):
                    ProgressHUD.showFailure()
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
        // iPad specific code
        alertController.popoverPresentationController?.sourceView = self.view
        let xOrigin = self.view.bounds.width / 2
        let popoverRect = CGRect(x: xOrigin, y: self.view.bounds.height, width: 1, height: 1)
        alertController.popoverPresentationController?.sourceRect = popoverRect
        alertController.popoverPresentationController?.permittedArrowDirections = .down
        
        self.present(alertController, animated: true)
    }
    
    private func setUserAlert(plan: Plan) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let adjust = UIAlertAction(title: "修改計畫次數", style: .default) { _ in
            self.planModifyPresent(plan: plan)
        }
        let delete = UIAlertAction(title: "刪除計畫", style: .destructive) { _ in
            self.showDeleteAlert(plan: plan)
        }
        if plan.planGroup == false {
            controller.addAction(adjust)
        }
        controller.addAction(delete)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        // iPad specific code
        controller.popoverPresentationController?.sourceView = self.view
        let xOrigin = self.view.bounds.width / 2
        let popoverRect = CGRect(x: xOrigin, y: self.view.bounds.height, width: 1, height: 1)
        controller.popoverPresentationController?.sourceRect = popoverRect
        controller.popoverPresentationController?.permittedArrowDirections = .down
        
        present(controller, animated: true, completion: nil)
    }
}
