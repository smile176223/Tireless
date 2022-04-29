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
        }
    }
    
    let shareManager = ShareManager()
    
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
    
    enum SectionItem: Hashable {
        case daily(WeeklyDays)
        case personalPlan(DefaultPlans)
        case joinGroup(JoinGroup)
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, SectionItem>
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>
    
    private var dataSource: DataSource?
    
    private var joinGroup: [JoinGroup]? {
        didSet {
            dataSource?.apply(snapshot(), animatingDifferences: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themeBG

        navigationController?.navigationBar.isHidden = true
        
        configureCollectionView()
        configureDataSource()
        configureDataSourceProvider()
        configureDataSourceSnapshot()
        
        viewModel.setDefault()
        
        viewModel.defaultPlans.bind { [weak self] plans in
            self?.plans = plans
        }
        
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
            NSCollectionLayoutDimension.absolute(400) : NSCollectionLayoutDimension.absolute(100)
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
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HomeViewCell.self)",
                                                                for: indexPath) as? HomeViewCell else {
                return UICollectionViewCell()
            }
            guard let dailyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HomeDailyViewCell.self)",
                                                                for: indexPath) as? HomeDailyViewCell else {
                return UICollectionViewCell()
            }
            
            switch item {
            case .daily(let text):
                if indexPath.section == 0, indexPath.row == 2 {
                    dailyCell.contentView.backgroundColor = .themeYellow
                }
                cell.textLabel.text = "\(text)"
                dailyCell.dailyWeekDayLabel.text = text.weekDays
                dailyCell.dailyDayLabel.text = text.days
                return dailyCell
            case .personalPlan(let plans):
                cell.textLabel.font = .bold(size: 30)
                cell.textLabel.text = plans.planName
                cell.imageView.image = UIImage(named: plans.planImage)
                cell.masksView.backgroundColor = .white
                return cell
            case .joinGroup(let joinGroup):
                cell.textLabel.font = .bold(size: 15)
                cell.textLabel.text = "\(joinGroup.planName)\n\(joinGroup.createdName)"
                if joinGroup.createdUserId == AuthManager.shared.currentUser {
                    cell.masksView.backgroundColor = .themeYellow
                } else {
                    cell.masksView.backgroundColor = .white
                }
                cell.imageView.alpha = 0
                return cell
            }
        })
    }
    private func configureDataSourceProvider() {
        dataSource?.supplementaryViewProvider = { (collectionView, _, indexPath) in
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
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                formatter.string(from: Date())
                headerDailyView.dateLabel.text = formatter.string(from: Date())
                headerDailyView.titleLabel.text = "每日運動計畫"
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
    
    private func configureDataSourceSnapshot() {
        dataSource?.apply(snapshot(), animatingDifferences: false)
    }
    
    private func snapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.daily, .personalPlan, .joinGroup])
        snapshot.appendItems(viewModel.weeklyDay.map({SectionItem.daily($0)}), toSection: .daily)
        snapshot.appendItems(viewModel.plans.map({SectionItem.personalPlan($0)}), toSection: .personalPlan)
        if let joinGroup = joinGroup {
            snapshot.appendItems(joinGroup.map({SectionItem.joinGroup($0)}), toSection: .joinGroup)
        }
        return snapshot
    }
    
//    @IBAction func photoButtonTap(_ sender: UIButton) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .camera
//        imagePicker.delegate = self
//        present(imagePicker, animated: true, completion: nil)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        
//        let fileManager = FileManager.default
//        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//        let imagePath = documentsPath?.appendingPathComponent("image.jpg")
//        
//        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            
//            let imageData = pickedImage.jpegData(compressionQuality: 0.75)
//            try? imageData?.write(to: imagePath!)
//            shareManager.uploadPicture(shareFile: ShareFiles(userId: "liamTest",
//                                                             shareName: UUID().uuidString,
//                                                             shareURL: imagePath!,
//                                                             createdTime: Date().millisecondsSince1970,
//                                                             content: "")) { _ in
//                self.dismiss(animated: true)
//            }
//        }
//    }
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
            detailVC.plan = plans?[indexPath.row]
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
