//
//  ShareWallViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit
import AVFoundation
import Lottie

class ShareWallViewController: UIViewController {
    
    var videoURL: URL?
    
    var lottieView: AnimationView?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private var currentIndex = 0
    
    let viewModel = ShareWallViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        tableView.backgroundColor = .white
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.register(UINib(nibName: "\(ShareWallViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ShareWallViewCell.self)")
        
        setupBind()
        lottieLoading()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        viewModel.fetchData()
        if let cell = tableView.visibleCells.first as? ShareWallViewCell {
            cell.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        if let cell = tableView.visibleCells.first as? ShareWallViewCell {
            cell.pause()
        }
    }
    
    func setupBind() {
        viewModel.shareFilesViewModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func lottieLoading() {
        lottieView = .init(name: "Loading")
        lottieView?.frame = view.bounds
        lottieView?.contentMode = .scaleAspectFit
        lottieView?.loopMode = .loop
        tableView.addSubview(lottieView ?? UIView())
        lottieView?.play()
    }
}

extension ShareWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.shareFilesViewModel.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ShareWallViewCell.self)",
            for: indexPath) as? ShareWallViewCell else {
            return UITableViewCell()
        }
        
        lottieView?.removeFromSuperview()
        
        let cellViewModel = self.viewModel.shareFilesViewModel.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.safeAreaLayoutGuide.layoutFrame.height + view.safeAreaInsets.top
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ShareWallViewCell {
            self.currentIndex = indexPath.row
            cell.play()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ShareWallViewCell {
            cell.pause()
        }
    }
}

extension ShareWallViewController: UIScrollViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: self.currentIndex, section: 0)) as? ShareWallViewCell
        cell?.replay()
    }

}
