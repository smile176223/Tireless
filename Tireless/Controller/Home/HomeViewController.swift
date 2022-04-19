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
    
    enum Section: Int, CaseIterable {
        case daily
        case personalPlan
        case groupPlan
        
        var columnCount: Int {
            switch self {
            case .daily:
                return 5
            case .personalPlan:
                return 3
            case .groupPlan:
                return 3
            }
        }
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    
    private var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .themeBG
        
        navigationController?.navigationBar.isHidden = true

        configureCollectionView()
        configureDataSource()
        
    }
    private func countDaily(_ day: Int) -> Int {
        let calendar = Calendar.current.date(byAdding: .day, value: day, to: Date())
        return calendar?.get(.day) ?? 0
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .themeBG
        
        collectionView.register(HomeHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(HomeHeaderView.self)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        // item
        // group
        // section
        // let layout = UICollectionViewCompositionalLayout(section: section)
        // return layout
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // find out what section we are working with
            guard let sectionType = Section(rawValue: sectionIndex) else {
                return nil
            }
            // how many columns
            let columns = sectionType.columnCount
            
            // what's the item's container => group
            // create the layout: item -> group -> section -> layout
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            // what's the group's container? => section
            let groupHeight = sectionIndex == 1 ?
            NSCollectionLayoutDimension.absolute(400) : NSCollectionLayoutDimension.fractionalWidth(0.25)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
//            let innergroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                           subitem: item,
//                                                           count: columns)
            
            let innergroup = sectionIndex == 1 ?
            NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                           subitem: item,
                                               count: columns) :
            NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                               count: columns)
//            let innergroup = columns == 3 ?
//            NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
//                                                           subitem: item,
//                                               count: columns) :
//            NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                           subitem: item,
//                                               count: columns)
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: groupHeight)
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innergroup])
            
            let section = NSCollectionLayoutSection(group: nestedGroup)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            
            // size options: .fractional, .absolute, .estimated
            // configure the header view
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind:
                                                                        UICollectionView.elementKindSectionHeader,
                                                                     alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return layout
    }
    
    private func configureDataSource() {
        // 1
        // setting up the data source
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            // configure the cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HomeViewCell.self)",
                                                                for: indexPath) as? HomeViewCell else {
                return UICollectionViewCell()
            }
            cell.textLabel.text = "\(item)"
            
            if indexPath.section == 0 { // first section
                cell.backgroundColor = .white
                cell.layer.cornerRadius = 12
                cell.textLabel.textColor = .black
            } else if indexPath.section == 1 {
                cell.backgroundColor = .themeYellow
                cell.imageView.image = UIImage(named: "Cover")
                cell.textLabel.font = cell.textLabel.font.withSize(30)
                cell.layer.cornerRadius = 12
            } else if indexPath.section == 2 {
                cell.backgroundColor = .themeYellow
                cell.imageView.image = UIImage(named: "Cover2")
                cell.layer.cornerRadius = 12
            }
            return cell
        })
        
        dataSource?.supplementaryViewProvider = { (collectionView, _, indexPath) in
            guard let headerView = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "\(HomeHeaderView.self)",
                for: indexPath) as? HomeHeaderView else {
                fatalError("could not dequeue a HeaderView")
            }
            headerView.textLabel.text = "\(Section.allCases[indexPath.section])".capitalized
            return headerView
        }
        let dayArray = ["\(countDaily(-2))",
                        "\(countDaily(-1))",
                        "\(countDaily(0))",
                        "\(countDaily(1))",
                        "\(countDaily(2))"]
        let personalPlan = ["Squat", "Plank", "PushUp"]
        let groupPlan = ["Squat X 10", "Plank X 7", "PushUp X 20", "Squat X 20", "PushUp X 30", "PushUp X 40"]
        
        // 2
        // setup initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.daily, .personalPlan, .groupPlan])
        snapshot.appendItems(dayArray, toSection: .daily)
        snapshot.appendItems(personalPlan, toSection: .personalPlan)
        snapshot.appendItems(groupPlan, toSection: .groupPlan)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    @IBAction func goToNext(_ sender: UIButton) {
        guard let poseVC = UIStoryboard.home.instantiateViewController(
            withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
        //        poseVC.hidesBottomBarWhenPushed = true
        //        self.navigationItem.backButtonTitle = ""
        //        self.navigationController?.pushViewController(poseVC, animated: true)
        poseVC.modalPresentationStyle = .fullScreen
        self.present(poseVC, animated: true)
    }
    
    func setupTitle() {
        let titleView = UIImageView()
        titleView.image = UIImage(named: "TirelessLogo")
        titleView.contentMode = .scaleAspectFill
        titleView.clipsToBounds = true
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        titleView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120).isActive = true
    }
    
    @IBAction func photoButtonTap(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imagePath = documentsPath?.appendingPathComponent("image.jpg")
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let imageData = pickedImage.jpegData(compressionQuality: 0.75)
            try? imageData?.write(to: imagePath!)
            shareManager.uploadPicture(shareFile: ShareFiles(userId: "liamTest",
                                                             shareName: UUID().uuidString,
                                                             shareURL: imagePath!,
                                                             createdTime: Date().millisecondsSince1970,
                                                             content: "")) { _ in
                self.dismiss(animated: true)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}
